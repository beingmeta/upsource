if test ! -z "${UPSOURCE_TRACE}"; then
    echo "upsource: running post.sh" >&2;
fi;
if test -d "${MOUNT}" || test -h "${MOUNT}"; then
    if test ! -z "${UPSOURCE_OWNER}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting owner=${UPSOURCE_OWNER} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chown -R ${UPSOURCE_OWNER} ${MOUNT};
    fi;
    if test ! -z "${UPSOURCE_GROUP}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting group=${UPSOURCE_GROUP} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chgrp -R ${UPSOURCE_GROUP} ${MOUNT};
    fi;
    if test ! -z "${UPSOURCE_MODE}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting mode=${UPSOURCE_MODE} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chmod -R ${UPSOURCE_MODE} ${MOUNT};
    fi;
else
    echo "(stdout) The directory ${MOUNT} wasn't created!" >&1;
    echo "(stderr) The directory ${MOUNT} wasn't created!" >&2;
fi;
