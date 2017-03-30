#! /bin/bash
#
# Update the version file each day for the daily build
#

# Exit on error
set -e

# Parsing logic

usage()
{
    echo "$0 <options>"
    echo
    echo "Valid options are:"
    echo "  -f:  Version file to update (mandatory option)"
    echo "  -h:  This message"
    echo "  -i:  Increment build number and set date"
    echo "  -r:  Set for release build"
    echo "  -v:  Verbose output"
    echo
    echo "With only the -f option specified, -i is assumed"

    exit 1
}

P_INCREMENT=0
P_RELEASE=0
VERBOSE=0

while getopts "h?f:irv" opt; do
    case "$opt" in
        h|\?)
            usage
            ;;
        f)
            VERSION_FILE=$OPTARG
            ;;

        i)
            P_INCREMENT=1
            ;;
        r)
            P_RELEASE=1
            ;;
        v)
            VERBOSE=1
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$@ " != " " ]; then
    echo "Parsing error: '$@' is unparsed, use -h for help" 1>& 2
    exit 1
fi

if [ -z "$VERSION_FILE" ]; then
    echo "Must specify -f qualifier (version file)" 1>& 2
    exit 1
fi

if [ ! -f $VERSION_FILE ]; then
    echo "Can't find file $VERSION_FILE" 1>& 2
    exit 1
fi

if [ ! -w $VERSION_FILE ]; then
    echo "File $VERSION_FILE is not writeable" 1>& 2
    exit 1
fi


# Set release build
if [ $P_RELEASE -ne 0 ]; then
    perl -i -pe "s/^([A-Z]*_BUILDVERSION_STATUS)=.*/\1=Release_Build/" $VERSION_FILE
    [ $VERBOSE -ne 0 ] && echo "Set BUILDVERSION_STATUS to \"Release_Build\""
    echo "WARNING: Never commit $VERSION_FILE with release build set!" 1>& 2
fi

exit 0

