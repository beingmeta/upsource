PREFIX=$(shell if test -f .prefix; then cat .prefix; else echo -n /usr; fi)
RUN=$(shell if test -f .run; then cat .run; else echo -n /var/run; fi)
SRCTAB=$(shell if test -f .srctab; then cat .srctab; else echo -n /etc/srctab; fi)
LIBDIR=${PREFIX}/lib/sourcemap
VARDIR=${VAR}/run/sourcemap
BINDIR=${PREFIX}/bin
INSTALLDIR=install -d
INSTALLBIN=install -m 555
INSTALLER=install

build: upsource sourcetab.awk .prefix .var .srctab

.prefix:
	echo ${PREFIX} > .prefix

.run:
	echo ${RUN} > .run

.srctab:
	echo ${SRCTAB} > .srctab

upsource: upsource.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" -e "s:@VAR@:${VARDIR}:g" < $< > $@
	chmod a+x $@
sourcetab.awk: sourcetab.awk.in .prefix
	sed -e "s:@LIBDIR@:${LIBDIR}:g" -e "s:@VAR@:${VARDIR}:g" < $< > $@

installdirs:
	${INSTALLDIR} ${VARDIR}
	${INSTALLDIR} ${LIBDIR}
	${INSTALLDIR} ${LIBDIR}/handlers

install: installdirs build
	${INSTALLBIN} upsource ${PREFIX}/bin
	${INSTALLBIN} handlers/git.upsource ${LIBDIR}/handlers
	${INSTALLBIN} handlers/svn.upsource ${LIBDIR}/handlers
	${INSTALLBIN} handlers/link.upsource ${LIBDIR}/handlers
	${INSTALLBIN} handlers/s3.upsource ${LIBDIR}/handlers
	${INSTALLER} config ${LIBDIR}/config
	${INSTALLER} etc/srctab.template ${SRCTAB}

clean:
	rm sourceup sourcetab.awk

.PHONY: installdirs install clean

