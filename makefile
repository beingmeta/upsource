ETC=$(shell if test -f .etc; then cat .etc; else echo -n /etc; fi)
PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo -n /var/run; fi)
INITSCRIPTS=etc/systemd-upsource.service etc/sysv-upsource.sh etc/upstart-upsource.conf
STATEFILES=.prefix .run .etc
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
	if diff .prefix .prefix.tmp;    \
	  then mv .prefix.tmp .prefix;  \
	else rm .prefix.tmp;            \
	fi

.run:
	echo ${RUN} > .run.tmp
	if diff .run .run.tmp;    \
	  then mv .run.tmp .run;  \
	else rm .run.tmp;            \
	fi

.etc:
	echo ${ETC} > .etc.tmp
	if diff .etc .etc.tmp;    \
	  then mv .etc.tmp .etc;  \
	else rm .etc.tmp;            \
	fi

upsource: upsource.in .prefix .run .etc
	sed -e "s:@LIBDIR@:${LIBDIR}:g" \
	    -e "s:@RUNDIR@:${RUNDIR}:g" \
	    -e "s:@ETC@:${ETC}:g" < $< > $@
	chmod a+x $@
sourcetab.awk: sourcetab.awk.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" \
	    -e "s:@RUNDIR@:${RUNDIR}:g" \
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
	if test ! -f ${DESTDIR}${ETC}/upsource.cfg.sh; then               \
	  ${INSTALLFILE} config.ex.sh ${DESTDIR}${ETC}/upsource.cfg.sh;   \
	else                                                              \
	  echo "Not overwriting current "                                 \
              ${DESTDIR}${ETC}/upsource.cfg.sh;                           \
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

upload-deb: dist/debs.signed
	cd dist; for change in *.changes; do \
	  dupload -c --nomail --to ${CODENAME} $${change} && \
	  rm -f $${change}; \
	done

debclean:
	rm -rf dist/upsource-* dist/debs.*

.PHONY: build config_state initscripts installdirs install clean debian upload-deb debclean 

