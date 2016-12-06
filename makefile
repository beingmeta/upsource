ETC=$(shell if test -f .etc; then cat .etc; else echo /etc; fi)
PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo /var/run; fi)
LOG=$(shell if test -f .log; then cat .log; else echo /var/log; fi)
AWK=$(shell if test -f .awk; then cat .awk; elif which gawk 2>&1 > /dev/null; then echo gawk; else echo awk; fi)
CWD=$(shell pwd)

VERSION=$(shell etc/gitversion)
BASEVERSION=$(shell echo ${VERSION} | sed -e "s:upsource-::g" -e "s:-[0-9]+$::g")
RELEASE=$(shell echo ${VERSION} | sed -e "s:upsource-[0-9]+\.[0-9]+-::g")

GPG=(shell which gpg2 || which gpg || echo gpg)
GPGID=repoman@beingmeta.com
CODENAME=beingmeta
DESTDIR=
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLFILE=install -D -m 644

LIBDIR=${PREFIX}/lib/upsource
RUNDIR=${RUN}/upsource
LOGDIR=${LOG}/upsource
BINDIR=${PREFIX}/bin

STATEFILES=.prefix .run .etc .awk .log
REWRITES=-e "s:@PREFIX@:${PREFIX}:g" \
	 -e "s:@LIBDIR@:${LIBDIR}:g" \
	 -e "s:@RUNDIR@:${RUNDIR}:g" \
	 -e "s:@LOGDIR@:${LOGDIR}:g" \
	 -e "s:@AWK@:${AWK}:g"       \
	 -e "s:@ETC@:${ETC}:g" 
SPEC_REWRITES=-e "s:@VERSION@:${VERSION}:g" \
	      -e "s:@BASEVERSION@:${BASEVERSION}:g" \
	      -e "s:@RELEASE@:${RELEASE}:g"

INITSCRIPTS=etc/systemd-upsource.service etc/sysv-upsource.sh etc/upstart-upsource.conf


etc/%: etc/%.in .state
	@sed ${REWRITES} < $< > $@
	@if test -x $<; then chmod a+x $@; fi
	@echo "Generated $@"
build: upsource sourcetab.awk config_state initscripts

initscripts: ${INITSCRIPTS}

config_state: ${STATEFILES}

upsource: upsource.in .state
	@sed ${REWRITES} < $< > $@
	@chmod a+x $@
	@echo "Generated $@"

sourcetab.awk: sourcetab.awk.in .state
	@sed ${REWRITES} < $< > $@
	@echo "Generated $@"

installdirs:
	${INSTALLDIR} ${ETC}
	${INSTALLDIR} ${ETC}/upsource.d
	${INSTALLDIR} ${DESTDIR}${PREFIX}/bin
	${INSTALLDIR} ${DESTDIR}${RUNDIR}
	${INSTALLDIR} ${DESTDIR}${LIBDIR}
	${INSTALLDIR} ${DESTDIR}${LIBDIR}/handlers
	${INSTALLDIR} ${DESTDIR}/lib/systemd/system
	${INSTALLDIR} ${DESTDIR}/etc/init.d
	${INSTALLDIR} ${DESTDIR}/etc/init

installconfig: installdirs
	if test ! -f ${DESTDIR}${ETC}/upsource.d/config; then             \
	  ${INSTALLFILE} config.ex.sh ${DESTDIR}${ETC}/upsource.d/config; \
	else                                                              \
	  echo "Not overwriting current "                                 \
              ${DESTDIR}${ETC}/upsource.d/config;                         \
	fi

install: installdirs build installconfig
	${INSTALLBIN} upsource ${DESTDIR}${PREFIX}/bin
	${INSTALLFILE} sourcetab.awk ${DESTDIR}${LIBDIR}
	${INSTALLBIN} handlers/git.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/svn.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/link.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/s3.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/pre.sh ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/post.sh ${DESTDIR}${LIBDIR}/handlers
	${INSTALLFILE} etc/systemd-upsource.service \
		${DESTDIR}/lib/systemd/system/upsource.service
	${INSTALLBIN} etc/sysv-upsource.sh ${DESTDIR}/etc/init.d/upsource
	${INSTALLFILE} etc/upstart-upsource.conf \
		${DESTDIR}/etc/init/upsource.conf

xinstall:
	sudo make install

clean:
	rm -f sourceup sourcetab.awk ${INITSCRIPTS} ${STATEFILES}

dist/debs.setup:
	(git archive --prefix=${VERSION}/                            \
	     -o dist/${VERSION}.tar HEAD) &&                         \
	(cd dist; tar -xf ${VERSION}.tar; rm ${VERSION}.tar) &&      \
	(cd dist; mv ${VERSION}/dist/debian ${VERSION}/debian) &&    \
	(etc/gitchangelog upsource stable                            \
	  < dist/debian/changelog                                    \
          > dist/${VERSION}/debian/changelog;) &&                    \
	touch $@;

dist/debs.built: dist/debs.setup
	(cd dist/${VERSION};                                         \
	 dpkg-buildpackage -A -us -uc -sa -rfakeroot) &&             \
	touch $@;

dist/debs.signed: dist/debs.built
	(cd dist; debsign --re-sign -k${GPGID} upsource_*_all.changes) && \
	touch $@;

debian: dist/debs.signed

dist/debs.uploaded: dist/debs.signed
	cd dist; for change in *.changes; do \
	  dupload -c --nomail --to ${CODENAME} $${change} && \
	  rm -f $${change}; \
	done
	touch $@

upload-debs upload-deb: dist/debs.uploaded

update-apt: dist/debs.uploaded
	ssh dev /srv/repo/apt/scripts/getincoming

debclean:
	rm -rf dist/upsource-* dist/debs.* dist/*.deb dist/*.changes

debfresh freshdeb newdeb: debclean
	make debian

dist/${VERSION}.tar:
	echo VERSION=${VERSION};
	echo BASEVERSION=${BASEVERSION};
	echo RELEASE=${RELEASE};
	(git archive --prefix=${VERSION}/                            \
	     -o dist/${VERSION}.tar HEAD) &&                         \
	(cd dist; tar -xf ${VERSION}.tar; rm ${VERSION}.tar) &&      \
	(cd dist; sed ${SPEC_REWRITES} < ${VERSION}/dist/upsource.spec.in > ${VERSION}/upsource.spec) &&    \
	(cd dist; tar -cf ${VERSION}.tar ${VERSION}; rm -rf ${VERSION}) &&    \
	touch $@;

dist/rpms.built: dist/${VERSION}.tar
	rpmbuild -ta \
	         --define="_rpmdir ${CWD}/dist" \
	         --define="_srcrpmdir ${CWD}/dist" \
	         --define="_gpg_name ${GPGID}" \
	         --define="__gpg ${GPG}" \
	   dist/${VERSION}.tar
	touch $@;

.PHONY: build config_state initscripts installdirs install clean \
	debian debclean debfresh freshdeb newdeb \
	upload-debs upload-deb update-apt

# Maintaining state files

.prefix:
	@echo ${PREFIX} > .prefix.tmp
	@if test ! -f .prefix; then           \
	  echo ${PREFIX} > .prefix;           \
	  rm .prefix.tmp;                     \
	elif diff .prefix .prefix.tmp; then   \
	  echo PREFIX changed                 \
	  mv .prefix.tmp .prefix;             \
	else rm .prefix.tmp;                  \
	fi

.run:
	@echo ${RUN} > .run.tmp
	@if test ! -f .run; then              \
	  echo ${RUN} > .run;                 \
	  rm .run.tmp;                        \
	elif diff .run .run.tmp; then         \
	  echo RUN changed                    \
	  mv .run.tmp .run;                   \
	else rm .run.tmp;                     \
	fi

.etc:
	@echo ${ETC} > .etc.tmp
	@if test ! -f .etc; then             \
	  echo ${ETC} > .etc;                \
	  rm .etc.tmp;                       \
	elif diff .etc .etc.tmp; then        \
	  echo ETC changed                   \
	  mv .etc.tmp .etc;                  \
	else rm .etc.tmp;                    \
	fi

.awk:
	@echo ${AWK} > .awk.tmp
	@if test ! -f .awk; then             \
	  echo ${AWK} > .awk;                \
	  rm .awk.tmp;                       \
	elif diff .awk .awk.tmp; then        \
	  echo AWK changed                   \
	  mv .awk.tmp .awk;                  \
	else rm .awk.tmp;                    \
	fi

.log:
	@echo ${LOG} > .log.tmp
	@if test ! -f .log; then             \
	  echo ${LOG} > .log;                \
	  rm .log.tmp;                       \
	elif diff .log .log.tmp; then        \
	  echo LOG changed                   \
	  mv .log.tmp .log;                  \
	else rm .log.tmp;                    \
	fi

.state: ${STATEFILES}
	@touch .state
	@ls -l .state

