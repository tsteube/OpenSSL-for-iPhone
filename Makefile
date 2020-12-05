OPENSSL_VERSION          := 1.1.1h
MACOSX_VERSION           := 11.0
RELEASE_DIR              := Release
RELEASE_OS_DIR           := ${RELEASE_DIR}/mac
RELEASE_CATALYIST_DIR    := ${RELEASE_DIR}/maccatalyst
RELEASE_IOS_DIR          := ${RELEASE_DIR}/iphoneos
RELEASE_SIMULATOR_DIR    := ${RELEASE_DIR}/iphonesimulator

.DEFAULT_GOAL := xcframework
.PHONY: all ios sim mac clean

all: mac sim cat ios
clean:
	rm -rf ${RELEASE_DIR}

${RELEASE_OS_DIR}/lib/openssl.a:
	[ -d ${RELEASE_OS_DIR} ] || mkdir -p ${RELEASE_OS_DIR}
	./build-libssl.sh --prefix=${RELEASE_OS_DIR} --version=${OPENSSL_VERSION} --targets="darwin64-x86_64-cc"
	libtool -no_warning_for_no_symbols -static -o ${RELEASE_OS_DIR}/lib/openssl.a ${RELEASE_OS_DIR}/lib/lib*
mac: ${RELEASE_OS_DIR}/lib/openssl.a
mac.clean:
	rm -rf ${RELEASE_OS_DIR}

${RELEASE_SIMULATOR_DIR}/lib/openssl.a: 
	[ -d ${RELEASE_SIMULATOR_DIR} ] || mkdir -p ${RELEASE_SIMULATOR_DIR}
	./build-libssl.sh --prefix=${RELEASE_SIMULATOR_DIR} --version=${OPENSSL_VERSION} --targets="ios-sim-cross-x86_64"	
	libtool -no_warning_for_no_symbols -static -o ${RELEASE_SIMULATOR_DIR}/lib/openssl.a ${RELEASE_SIMULATOR_DIR}/lib/lib*
sim: ${RELEASE_SIMULATOR_DIR}/lib/openssl.a
sim.clean:
	rm -rf ${RELEASE_SIMULATOR_DIR}

${RELEASE_CATALYIST_DIR}/lib/openssl.a: 
	[ -d ${RELEASE_CATALYIST_DIR} ] || mkdir -p ${RELEASE_CATALYIST_DIR}
	./build-libssl.sh --prefix=${RELEASE_CATALYIST_DIR} --version=${OPENSSL_VERSION} --targets="mac-catalyst-x86_64"
	libtool -no_warning_for_no_symbols -static -o ${RELEASE_CATALYIST_DIR}/lib/openssl.a ${RELEASE_CATALYIST_DIR}/lib/lib*
cat: ${RELEASE_CATALYIST_DIR}/lib/openssl.a
cat.clean:
	rm -rf ${RELEASE_CATALYIST_DIR}

${RELEASE_IOS_DIR}/arm64/lib/openssl.a: 
	[ -d ${RELEASE_IOS_DIR}/arm64 ] || mkdir -p ${RELEASE_IOS_DIR}/arm64
	./build-libssl.sh --prefix=${RELEASE_IOS_DIR}/arm64 --version=${OPENSSL_VERSION} --targets="ios64-cross-arm64"
	libtool -no_warning_for_no_symbols -static -o ${RELEASE_IOS_DIR}/arm64/lib/openssl.a ${RELEASE_IOS_DIR}/arm64/lib/lib*
ios.arm64: ${RELEASE_IOS_DIR}/arm64/lib/openssl.a
${RELEASE_IOS_DIR}/arm64e/lib/openssl.a: 
	[ -d ${RELEASE_IOS_DIR}/arm64e ] || mkdir -p ${RELEASE_IOS_DIR}/arm64e
	./build-libssl.sh --prefix=${RELEASE_IOS_DIR}/arm64e --version=${OPENSSL_VERSION} --targets="ios64-cross-arm64e"
	libtool -no_warning_for_no_symbols -static -o ${RELEASE_IOS_DIR}/arm64e/lib/openssl.a ${RELEASE_IOS_DIR}/arm64e/lib/lib*
ios.arm64e: ${RELEASE_IOS_DIR}/arm64e/lib/openssl.a
${RELEASE_IOS_DIR}/openssl.framework:
	[ -d ${RELEASE_IOS_DIR} ] || mkdir -p ${RELEASE_IOS_DIR}
	./build-libssl.sh --prefix=${RELEASE_IOS_DIR} --version=${OPENSSL_VERSION} --targets="ios64-cross-arm64 ios64-cross-arm64e mac-catalyst-x86_64"
	./create-openssl-framework.sh --prefix=${RELEASE_IOS_DIR} --platforms=MacOSX,iPhoneOS
ios.cross: ${RELEASE_IOS_DIR}/openssl.framework
ios.clean:
	rm -rf ${RELEASE_IOS_DIR}

xcframework: mac sim cat ios.arm64 xcframework.clean
	xcodebuild -create-xcframework \
	  -library ${RELEASE_OS_DIR}/lib/openssl.a -headers ${RELEASE_OS_DIR}/include/ \
	  -library ${RELEASE_SIMULATOR_DIR}/lib/openssl.a -headers ${RELEASE_SIMULATOR_DIR}/include/ \
	  -library ${RELEASE_CATALYIST_DIR}/lib/openssl.a -headers ${RELEASE_CATALYIST_DIR}/include/ \
	  -library ${RELEASE_IOS_DIR}/arm64/lib/openssl.a -headers ${RELEASE_IOS_DIR}/arm64/include/ \
	  -output ${RELEASE_DIR}/openssl.xcframework
xcframework.clean:
	rm -rf ${RELEASE_DIR}/openssl.xcframework
