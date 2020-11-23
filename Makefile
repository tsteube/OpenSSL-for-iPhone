OPENSSL_VERSION          := 1.1.1h
MACOSX_VERSION           := 10.15
RELEASE_DIR              := Release
RELEASE_OS_DIR           := ${RELEASE_DIR}/mac
RELEASE_CATALYIST_DIR    := ${RELEASE_DIR}/maccatalyst
RELEASE_IOS_DIR          := ${RELEASE_DIR}/iphone
RELEASE_SIMULATOR_DIR    := ${RELEASE_DIR}/iphonesimulator

.PHONY: all ios sim mac clean

all: mac sim cat ios
clean:
	rm -rf ${RELEASE_DIR}

mac:
	[ -d ${RELEASE_OS_DIR} ] || mkdir -p ${RELEASE_OS_DIR}
	cd ${RELEASE_OS_DIR} && ../../build-libssl.sh --version=${OPENSSL_VERSION} --targets="darwin64-x86_64-cc" --macosx-sdk=${MACOSX_VERSION}
mac.clean:
	rm -rf ${RELEASE_OS_DIR}

sim:
	[ -d ${RELEASE_SIMULATOR_DIR} ] || mkdir -p ${RELEASE_SIMULATOR_DIR}
	cd ${RELEASE_SIMULATOR_DIR} && ../../build-libssl.sh --version=${OPENSSL_VERSION} --targets="ios-sim-cross-x86_64"
sim.clean:
	rm -rf ${RELEASE_SIMULATOR_DIR}

cat:
	[ -d ${RELEASE_CATALYIST_DIR} ] || mkdir -p ${RELEASE_CATALYIST_DIR}
	cd ${RELEASE_CATALYIST_DIR} && ../../build-libssl.sh --version=${OPENSSL_VERSION} --targets="mac-catalyst-x86_64" --macosx-sdk=${MACOSX_VERSION}
cat.clean:
	rm -rf ${RELEASE_CATALYIST_DIR}

ios:
	[ -d ${RELEASE_IOS_DIR} ] || mkdir -p ${RELEASE_IOS_DIR}
	cd ${RELEASE_IOS_DIR} && ../../build-libssl.sh --version=${OPENSSL_VERSION} --targets="ios64-cross-arm64 ios64-cross-arm64e ios-sim-cross-x86_64"
ios.clean:
	rm -rf ${RELEASE_IOS_DIR}

 
