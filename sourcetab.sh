SOURCETAB=/etc/srctab
LIBROOT=
THISDIR=`dirname $0`
for dir in ${THISDIR} /usr/lib/sourcetab /opt/local/lib/sourcetab /usr/local/lib/sourcetab; do
    if [$"LIBROOT" = ""]; then
	if [-d ${dir}]; then
	    LIBROOT=${dir};
	fi;
    fi;
done;

showusage( ) {
    echo "Usage: fdstatus <activity> ... ";
    echo "Usage: fdstatus --list";
    echo "Usage: fdstatus --files";
    echo "Usage: fdstatus --compact";
}
process_sourcetab( line ) {
    
}


