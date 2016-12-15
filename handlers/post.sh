if test ! -z "${OWNER}"; then
   ${UPSOURCESUDO:-} chown -R ${OWNER} ${MOUNT};
fi;
if test ! -z "${GROUP}"; then
   ${UPSOURCESUDO:-} chgrp -R ${GROUP} ${MOUNT};
fi;
if test ! -z "${MODE}"; then
   ${UPSOURCESUDO:-} chmod -R ${MODE} ${MOUNT};
fi;
