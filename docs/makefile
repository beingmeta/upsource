RONN_MANUAL       = S3Scripts
RONN_ORGANIZATION = beingmeta.com

PAGES=s3checkout s3update s3commit s3src s3root s3setroot s3setopts

man/%: ronn/%.ronn
	ronn --roff < $< > $@
man.html/%.html: ronn/%.ronn
	ronn --html < $< > $@
man.html.include/%.html: ronn/%.ronn
	ronn --fragment < $< > $@

man manpages:
	@for page in ${PAGES}; do make man/${page}; done

html htmlpages man.html:
	@for page in ${PAGES}; do make man.html/${page}.html; done

htmlinclude man.html.include:
	@for page in ${PAGES}; do make man.html/${page}.html; done

.PHONY: man manpages man.html man.html.include

