PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo -n /var/run; fi)
SRCTAB=$(shell if test -f .srctab; then cat .srctab; else echo -n /etc/srctab; fi)
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

build: upsource sourcetab.awk .prefix .run .srctab

.prefix:
	echo ${PREFIX} > .prefix

.run:
	echo ${RUN} > .run

.srctab:
	echo ${SRCTAB} > .srctab

upsource: upsource.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" -e "s:@RUNDIR@:${RUNDIR}:g" < $< > $@
	chmod a+x $@
sourcetab.awk: sourcetab.awk.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" -e "s:@RUNDIR@:${RUNDIR}:g" < $< > $@

installdirs:
	${INSTALLDIR} ${DESTDIR}${PREFIX}/bin
	${INSTALLDIR} ${DESTDIR}${RUNDIR}
	${INSTALLDIR} ${DESTDIR}${LIBDIR}
	${INSTALLDIR} ${DESTDIR}${LIBDIR}/handlers
	${INSTALLDIR} ${DESTDIR}/lib/systemd/system
	${INSTALLDIR} ${DESTDIR}/etc/init.d
	${INSTALLDIR} ${DESTDIR}/etc/init

install: installdirs build
	${INSTALLBIN} upsource ${DESTDIR}${PREFIX}/bin
	${INSTALLFILE} sourcetab.awk ${DESTDIR}${LIBDIR}
	${INSTALLBIN} handlers/git.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/svn.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/link.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/s3.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLFILE} config ${DESTDIR}${LIBDIR}/config
	${INSTALLFILE} etc/srctab.template ${DESTDIR}${SRCTAB}
	${INSTALLFILE} etc/systemd-upsource.service ${DESTDIR}/lib/systemd/system/upsource.service
	${INSTALLBIN} etc/sysv-upsource.sh ${DESTDIR}/etc/init.d/upsource
	${INSTALLFILE} etc/upstart-upsource.conf ${DESTDIR}/etc/init/upsource.conf

clean:
	rm sourceup sourcetab.awk

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

.PHONY: installdirs install clean debian upload-deb debclean

