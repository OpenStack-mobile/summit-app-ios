# Copy CoreSummit environment source files
cp -rf ${BUDDYBUILD_SECURE_FILES}/Production.swift ./OpenStack\ Summit/CoreSummit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Staging.swift ./OpenStack\ Summit/CoreSummit/

# Copy iOS environment source files
cp -rf ${BUDDYBUILD_SECURE_FILES}/AppConsumerKey.swift ./OpenStack\ Summit/OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Beta.entitlements ./OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/R.generated.swift ./OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/GoogleService-Info.plist ./OpenStack\ Summit/GoogleServices/Beta/

# Install Vendor frameworks
unzip -o ${BUDDYBUILD_SECURE_FILES}/VendorFabric.zip
unzip -o ${BUDDYBUILD_SECURE_FILES}/VendorFirebase.zip

# Download and install Google Maps
wget https://www.gstatic.com/cpdc/aa3052925ceeea2d-GoogleMaps-1.13.2.tar.gz
tar -zxvf aa3052925ceeea2d-GoogleMaps-1.13.2.tar.gz Frameworks/GoogleMaps.framework
cp -rf ./Frameworks ./Vendor

# Install Carthage dependencies for watchOS and tvOS
carthage bootstrap --platform watchOS --verbose --toolchain com.apple.dt.toolchain.Swift_2_3
carthage bootstrap --platform tvOS --verbose --toolchain com.apple.dt.toolchain.Swift_2_3
