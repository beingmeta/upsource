if test ! -z "${UPSOURCE_TRACE}"; then
    echo "upsource: running post.sh" >&2;
fi;
if test -d "${MOUNT}" || test -h "${MOUNT}"; then
    if test ! -z "${OWNER}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting owner=${OWNER} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chown -R ${OWNER} ${MOUNT};
    fi;
    if test ! -z "${GROUP}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting group=${GROUP} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chgrp -R ${GROUP} ${MOUNT};
    fi;
    if test ! -z "${FILEMODE}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting mode=${FILEMODE} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chmod -R ${FILEMODE} ${MOUNT};
    fi;
else
    echo "(stdout) The directory ${MOUNT} wasn't created!" >&1;
    echo "(stderr) The directory ${MOUNT} wasn't created!" >&2;
fi;
