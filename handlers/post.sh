if test ! -z "${OWNER}"; then
   chown -R ${OWNER} ${MOUNT};
fi;
if test ! -z "${GROUP}"; then
   chgrp -R ${GROUP} ${MOUNT};
fi;
if test ! -z "${MODE}"; then
   chmod -R ${MODE} ${MOUNT};
fi;
