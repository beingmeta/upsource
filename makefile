PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo -n /var/run; fi)
SRCTAB=$(shell if test -f .srctab; then cat .srctab; else echo -n /etc/srctab; fi)
VERSION=$(shell etc/gitversion)
DESTROOT=
LIBDIR=${PREFIX}/lib/sourcemap
RUNDIR=${RUN}/upsource
BINDIR=${PREFIX}/bin
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLER=install

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
	${INSTALLDIR} ${DESTROOT}${RUNDIR}
	${INSTALLDIR} ${DESTROOT}${LIBDIR}
	${INSTALLDIR} ${DESTROOT}${LIBDIR}/handlers

install: installdirs build
	${INSTALLBIN} upsource ${DESTROOT}${PREFIX}/bin
	${INSTALLBIN} handlers/git.upsource ${DESTROOT}${LIBDIR}/handlers
	${INSTALLBIN} handlers/svn.upsource ${DESTROOT}${LIBDIR}/handlers
	${INSTALLBIN} handlers/link.upsource ${DESTROOT}${LIBDIR}/handlers
	${INSTALLBIN} handlers/s3.upsource ${DESTROOT}${LIBDIR}/handlers
	${INSTALLER} config ${DESTROOT}{$LIBDIR}/config
	${INSTALLER} etc/srctab.template ${DESTROOT}${SRCTAB}

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
debmake: debstart
	cd dist/${VERSION}; dpkg-buildpackage -A -us -uc -sa -rfakeroot

.PHONY: installdirs install clean

