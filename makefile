ETC=$(shell if test -f .etc; then cat .etc; else echo /etc; fi)
PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo /var/run; fi)
AWK=$(shell if test -f .awk; then cat .awk; elif which gawk 2&>1 > /dev/null; then echo gawk; else echo awk; fi)
INITSCRIPTS=etc/systemd-upsource.service etc/sysv-upsource.sh etc/upstart-upsource.conf
STATEFILES=.prefix .run .etc .awk
VERSION=$(shell etc/gitversion)
GPGID=repoman@beingmeta.com
CODENAME=beingmeta
DESTDIR=
LIBDIR=${PREFIX}/lib/upsource
RUNDIR=${RUN}/upsource
BINDIR=${PREFIX}/bin
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLFILE=install -D -m 644


etc/%: etc/%.in
	sed -e "s:@LIBDIR@:${LIBDIR}:g" \
	    -e "s:@RUNDIR@:${RUNDIR}:g" \
	    -e "s:@ETC@:${ETC}:g" < $< > $@
	if test -x $<; then chmod a+x $@; fi

build: upsource sourcetab.awk config_state initscripts

initscripts: ${INITSCRIPTS}

config_state: ${STATEFILES}

.prefix:
	echo ${PREFIX} > .prefix.tmp
	if test ! -f .prefix; then        \
	  echo ${PREFIX} > .prefix;          \
	  rm .prefix.tmp;                 \
	elif diff .prefix .prefix.tmp;       \
	  then mv .prefix.tmp .prefix;       \
	else rm .prefix.tmp;              \
	fi

.run:
	echo ${RUN} > .run.tmp
	if test ! -f .run; then        \
	  echo ${RUN} > .run;          \
	  rm .run.tmp;                 \
	elif diff .run .run.tmp;       \
	  then mv .run.tmp .run;       \
	else rm .run.tmp;              \
	fi

.etc:
	echo ${ETC} > .etc.tmp
	if test ! -f .etc; then        \
	  echo ${ETC} > .etc;          \
	  rm .etc.tmp;                 \
	elif diff .etc .etc.tmp;       \
	  then mv .etc.tmp .etc;       \
	else rm .etc.tmp;              \
	fi

.awk:
	echo ${AWK} > .awk.tmp
	if test ! -f .awk; then        \
	  echo ${AWK} > .awk;          \
	  rm .awk.tmp;                 \
	elif diff .awk .awk.tmp;       \
	  then mv .awk.tmp .awk;       \
	else rm .awk.tmp;              \
	fi

upsource: upsource.in .prefix .run .etc .awk
	sed -e "s:@PREFIX@:${PREFIX}:g" \
	    -e "s:@LIBDIR@:${LIBDIR}:g" \
	    -e "s:@RUNDIR@:${RUNDIR}:g" \
	    -e "s:@AWK@:${AWK}:g"       \
	    -e "s:@ETC@:${ETC}:g" < $< > $@
	chmod a+x $@
sourcetab.awk: sourcetab.awk.in .prefix
	sed -e "s:@PREFIX@:${PREFIX}:g" \
	    -e "s:@LIBDIR@:${LIBDIR}:g" \
	    -e "s:@RUNDIR@:${RUNDIR}:g" \
	    -e "s:@AWK@:${AWK}:g"       \
	    -e "s:@ETC@:${ETC}:g" < $< > $@

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
	if test ! -f ${DESTDIR}${ETC}/srctab; then                        \
	  ${INSTALLFILE} etc/srctab.template ${DESTDIR}${ETC}/srctab;     \
	else                                                              \
	  echo "Not overwriting current " ${DESTDIR}${ETC}/srctab;        \
	fi
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
	(git archive --prefix=${VERSION}/ -o dist/${VERSION}.tar HEAD) && \
	(cd dist; tar -xf ${VERSION}.tar; rm ${VERSION}.tar) && \
	(cd dist; mv ${VERSION}/dist/debian ${VERSION}/debian) && \
	(etc/gitchangelog upsource stable < dist/debian/changelog > dist/${VERSION}/debian/changelog;) && \
	touch $@;

dist/debs.built: dist/debs.setup
	(cd dist/${VERSION}; dpkg-buildpackage -A -us -uc -sa -rfakeroot) && \
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

.PHONY: build config_state initscripts installdirs install clean \
	debian debclean debfresh freshdeb newdeb \
	upload-debs upload-deb update-apt

