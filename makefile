PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
LIBDIR=${PREFIX}/lib/sourcemap
BINDIR=${PREFIX}/bin
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLER=install

all: sourceup sourcetab.awk .prefix

.prefix:
	echo ${PREFIX} > .prefix

sourceup: sourceup.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" < $< > $@
	chmod a+x $@
sourcetab.awk: sourcetab.awk.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" < $< > $@

installdirs:
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

