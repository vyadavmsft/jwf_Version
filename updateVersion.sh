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

# Set default behavior
[ $P_RELEASE -eq 0 ] && P_INCREMENT=1

# Increment build number
if [ $P_INCREMENT -ne 0 ]; then
    VERSION_OLD=`grep '^[A-Z]*_BUILDVERSION_BUILDNR' $VERSION_FILE | cut -d= -f2`
    DATE_OLD=`grep '^[A-Z]*_BUILDVERSION_DATE' $VERSION_FILE | cut -d= -f2`

    VERSION_NEW=$(( $VERSION_OLD + 1 ))
    DATE_NEW=`date +%Y%m%d`

    if [ $DATE_NEW -eq $DATE_OLD ]; then
        if [ $VERBOSE -ne 0 ]; then
            echo "Date has not changed.  Incrementing build number only."
            echo "Updated version number, Was: $VERSION_OLD, Now $VERSION_NEW"
        fi
    else
        if [ $VERBOSE -ne 0 ]; then
            echo "Updated release date,   Was: $DATE_OLD, Now $DATE_NEW"
            echo "Date has changed.  Resetting build number to 1"
        fi
        #  Set it to zero here; it will be incremented by the runner
        VERSION_NEW=0
    fi

    perl -i -pe "s/(^[A-Z]*_BUILDVERSION_BUILDNR)=.*/\1=$VERSION_NEW/" $VERSION_FILE
    perl -i -pe "s/(^[A-Z]*_BUILDVERSION_DATE)=.*/\1=$DATE_NEW/" $VERSION_FILE
fi

export JWF_BUILDVERSION_BUILDNR=$DATE_NEW"__"$VERSION_NEW
echo "New version = $JWF_BUILDVERSION_BUILDNR"

# Set release build
if [ $P_RELEASE -ne 0 ]; then
    perl -i -pe "s/^([A-Z]*_BUILDVERSION_STATUS)=.*/\1=Release_Build/" $VERSION_FILE
    [ $VERBOSE -ne 0 ] && echo "Set BUILDVERSION_STATUS to \"Release_Build\""
    echo "WARNING: Never commit $VERSION_FILE with release build set!" 1>& 2
fi

exit 0

