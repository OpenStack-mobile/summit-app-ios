# Copy CoreSummit environment source files
cp -rf ${BUDDYBUILD_SECURE_FILES}/Production.swift ./OpenStack\ Summit/CoreSummit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Staging.swift ./OpenStack\ Summit/CoreSummit/

# Copy iOS environment source files
cp -rf ${BUDDYBUILD_SECURE_FILES}/AppSecrets.swift ./OpenStack\ Summit/OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Debug.entitlements ./OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Beta.entitlements ./OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/Release.entitlements ./OpenStack\ Summit/
cp -rf ${BUDDYBUILD_SECURE_FILES}/OpenStackSummitTV.entitlements ./OpenStack\ Summit/OpenStackSummitTV/
cp -rf ${BUDDYBUILD_SECURE_FILES}/OpenStackSummitTVService.entitlements ./OpenStack\ Summit/OpenStackSummitTVService/
mkdir ./OpenStack\ Summit/GoogleServices
mkdir ./OpenStack\ Summit/GoogleServices/Beta
mkdir ./OpenStack\ Summit/GoogleServices/Release
cp -rf ${BUDDYBUILD_SECURE_FILES}/Beta-GoogleService-Info.plist ./OpenStack\ Summit/GoogleServices/Beta/GoogleService-Info.plist
cp -rf ${BUDDYBUILD_SECURE_FILES}/Release-GoogleService-Info.plist ./OpenStack\ Summit/GoogleServices/Release/GoogleService-Info.plist

# Install Vendor frameworks
unzip -o ${BUDDYBUILD_SECURE_FILES}/VendorFabric.zip
unzip -o ${BUDDYBUILD_SECURE_FILES}/VendorFirebase.zip

# Download and install Google Maps
wget https://www.gstatic.com/cpdc/aa3052925ceeea2d-GoogleMaps-1.13.2.tar.gz
tar -zxvf aa3052925ceeea2d-GoogleMaps-1.13.2.tar.gz Frameworks/GoogleMaps.framework
cp -rf ./Frameworks/* ./Vendor

# Install BuddyBuild SDK
wget https://s3-us-west-2.amazonaws.com/buddybuild-sdk-builds/master/BuddyBuildSDK.framework.zip
unzip BuddyBuildSDK.framework.zip
rm -f BuddyBuildSDK.framework.zip
cp -rf ./BuddyBuildSDK.framework ./Vendor
