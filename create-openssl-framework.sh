#!/bin/sh

FWNAME=openssl

echo_help()
{
  echo "Usage: $0 [options...]"
  echo "Generic options"
  echo " -h, --help                        Print help (this message)"
  echo "     --dynamic                     Create dynamic framework"
  echo " -v, --verbose                     Enable verbose logging"
  echo "     --prefix=INSTALL_PREFIX       OpenSSL installation directory to build (defaults to current directory)"
  echo "     --platforms=PLATTFORMS        Supported Platforms"
}

# Process command line arguments
for i in "$@"
do
case $i in
  --archs=*)
    ARCHS="${i#*=}"
    shift
    ;;
  -h|--help)
    echo_help
    exit
    ;;
  --platforms=*)
    IFS=,
    read -ra PLATFORMS <<< "${i#*=}" # str is read into an array as tokens separated by IFS
    for PLATFORM in "${PLATFORMS[@]}"; do # access each element of array
        SUPPORTED_PLATFORMS="${SUPPORTED_PLATFORM} <string>$PLATFORM</string>"
    done
    shift
    ;;
  -d|--dynamic)
    DYNAMIC=1
    ;;
  -v|--verbose)
    LOG_VERBOSE="verbose"
    ;;
  --prefix=*)
    INSTALL_PREFIX="${i#*=}"
    shift
    ;;
  *)
    echo "Unknown argument: ${i}"
    ;;
esac
done

if [[ -z $INSTALL_PREFIX ]]; then
  INSTALL_PREFIX=$(pwd)
elif [[ $INSTALL_PREFIX != /* ]]; then
  # use absolute path
  INSTALL_PREFIX="$(pwd)/${INSTALL_PREFIX}"
fi

if [ ! -d ${INSTALL_PREFIX}/lib ]; then
    echo "Please run build-libssl.sh first!"
    exit 1
fi

if [ -d ${INSTALL_PREFIX}/$FWNAME.framework ]; then
    echo "Removing previous $FWNAME.framework copy"
    rm -rf $FWNAME.framework
fi

if [ -n "${DYNAMIC}" ]; then
    LIBTOOL_FLAGS="-dynamic -undefined dynamic_lookup -ios_version_min 12.0"
else
    LIBTOOL_FLAGS="-static"
fi

echo "Creating $FWNAME.framework"
mkdir -p ${INSTALL_PREFIX}/$FWNAME.framework/Headers
libtool -no_warning_for_no_symbols $LIBTOOL_FLAGS -o ${INSTALL_PREFIX}/$FWNAME.framework/$FWNAME ${INSTALL_PREFIX}/lib/libcrypto.a ${INSTALL_PREFIX}/lib/libssl.a
cp -r ${INSTALL_PREFIX}/include/$FWNAME/* ${INSTALL_PREFIX}/$FWNAME.framework/Headers/

cat > ${INSTALL_PREFIX}/$FWNAME.framework/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>English</string>
  <key>CFBundleIdentifier</key>
  <string>${FWNAME}</string>
	<key>CFBundleExecutable</key>
	<string>${FWNAME}</string>	
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>CFBundleSupportedPlatforms</key>
  <array>
    $SUPPORTED_PLATFORM
  </array>
</dict>
</plist>
EOF
# sign binary with empty signatur
/usr/bin/codesign --force --sign - "${INSTALL_PREFIX}/$FWNAME.framework/$FWNAME"

echo "Created $FWNAME.framework"

check_bitcode=`otool -l ${INSTALL_PREFIX}/$FWNAME.framework/$FWNAME | grep __bitcode`
if [ -z "$check_bitcode" ]
then
  echo "INFO: $FWNAME.framework doesn't contain Bitcode"
else
  echo "INFO: $FWNAME.framework contains Bitcode"
fi
