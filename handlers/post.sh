if test ! -z "${UPSOURCE_OWNER}"; then
   echo Setting owner=${UPSOURCE_OWNER} for ${MOUNT} > 2;
   ${UPSOURCESUDO:-} chown -R ${UPSOURCE_OWNER} ${MOUNT};
fi;
if test ! -z "${UPSOURCE_GROUP}"; then
   echo Setting group=${UPSOURCE_GROUP} for ${MOUNT} > 2;
   ${UPSOURCESUDO:-} chgrp -R ${UPSOURCE_GROUP} ${MOUNT};
fi;
if test ! -z "${UPSOURCE_MODE}"; then
   echo Setting mode=${UPSOURCE_MODE} for ${MOUNT} > 2;
   ${UPSOURCESUDO:-} chmod -R ${UPSOURCE_MODE} ${MOUNT};
fi;
