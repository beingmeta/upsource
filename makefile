PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo -n /var/run; fi)
SRCTAB=$(shell if test -f .srctab; then cat .srctab; else echo -n /etc/srctab; fi)
VERSION=$(shell etc/gitversion)
DESTDIR=
LIBDIR=${PREFIX}/lib/upsource
RUNDIR=${RUN}/upsource
BINDIR=${PREFIX}/bin
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLER=install -D

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

install: installdirs build
	${INSTALLBIN} upsource ${DESTDIR}${PREFIX}/bin
	${INSTALLBIN} handlers/git.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/svn.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/link.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLBIN} handlers/s3.upsource ${DESTDIR}${LIBDIR}/handlers
	${INSTALLER} config ${DESTDIR}${LIBDIR}/config
	${INSTALLER} etc/srctab.template ${DESTDIR}${SRCTAB}

clean:
	rm sourceup sourcetab.awk

dist/.unpacked: 
	git archive --prefix=${VERSION}/ -o dist/${VERSION}.tar HEAD
	cd dist; tar -xf ${VERSION}.tar; rm ${VERSION}.tar;
	cd dist; mv ${VERSION}/dist/debian ${VERSION}/debian
	etc/gitchangelog upsource stable < dist/debian/changelog > dist/${VERSION}/debian/changelog;
	touch dist/.unpacked

debclean:
	rm -rf dist/upsource-* dist/.unpacked
debstart: dist/.unpacked

debfresh: debclean
	make debstart

debmake: debstart
	cd dist/${VERSION}; dpkg-buildpackage -A -us -uc -sa -rfakeroot

.PHONY: installdirs install clean

