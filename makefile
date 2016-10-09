PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
VAR=$(shell if test -f .var; then cat .var; else echo -n /var; fi)
LIBDIR=${PREFIX}/lib/sourcemap
VARDIR=${VAR}/run/sourcemap
BINDIR=${PREFIX}/bin
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLER=install

build: upsource sourcetab.awk .prefix .var

.prefix:
	echo ${PREFIX} > .prefix

.var:
	echo ${VAR} > .var

upsource: upsource.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" -e "s:@VAR@:${VARDIR}:g" < $< > $@
	chmod a+x $@
sourcetab.awk: sourcetab.awk.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" -e "s:@VAR@:${VARDIR}:g" < $< > $@

installdirs:
	${INSTALLDIR} ${VARDIR}
	${INSTALLDIR} ${LIBDIR}
	${INSTALLDIR} ${LIBDIR}/handlers

install: installdirs
	${INSTALLBIN} sourceup ${PREFIX}/bin
	${INSTALLBIN} handlers/git ${LIBDIR}/handlers/git
	${INSTALLBIN} handlers/svn ${LIBDIR}/handlers/svn
	${INSTALLBIN} handlers/link ${LIBDIR}/handlers/link
	${INSTALLBIN} handlers/s3 ${LIBDIR}/handlers/s3
	${INSTALLER} config ${LIBDIR}/config

clean:
	rm sourceup sourcetab.awk

.PHONY: installdirs install clean

