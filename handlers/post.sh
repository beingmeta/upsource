export UPSOURCE_OWNER=${UPSOURCE_OWNER:-${OWNER}}
export UPSOURCE_GROUP=${UPSOURCE_GROUP:-${GROUP}}
export UPSOURCE_FILEMODE=${UPSOURCE_FILEMODE:-${FILEMODE}}

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
    if test ! -z "${UPSOURCE_FILEMODE}"; then
	if test ! -z "${UPSOURCE_TRACE}"; then
	    echo Setting mode=${UPSOURCE_FILEMODE} for ${MOUNT} >&2;
	fi;
	${UPSOURCESUDO:-} chmod -R ${UPSOURCE_FILEMODE} ${MOUNT};
    fi;
else
    echo "(stdout) The directory ${MOUNT} wasn't created!" >&1;
    echo "(stderr) The directory ${MOUNT} wasn't created!" >&2;
fi;
