# OpenStack Foundation Summit App

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=589d42c2ac95bf01009695f6&branch=develop&build=latest)](https://dashboard.buddybuild.com/apps/589d42c2ac95bf01009695f6/build/latest?branch=develop)

The official app for the OpenStack Summit. ([iTunes](https://itunes.apple.com/us/app/openstack-foundation-summit/id1071261846?mt=8))

Supports iOS, watchOS and tvOS.

## Setup

1. Fetch [Carthage](https://github.com/Carthage/Carthage) dependencies.

	```
	carthage bootstrap
	```
2. Download [Google Maps SDK](https://www.gstatic.com/cpdc/aa3052925ceeea2d-GoogleMaps-1.13.2.tar.gz), [Firebase SDK](https://dl.google.com/firebase/sdk/ios/3_11_1/Firebase-3.11.1.zip) (frameworks in Analytics and Messaging folders), [Fabric](https://kit-downloads.fabric.io/cocoapods/fabric/1.6.9/fabric.zip), [Crashlytics](https://kit-downloads.fabric.io/cocoapods/crashlytics/3.8.1/crashlytics.zip) and copy to `Vendor` folder.

3. Generate .swift out of sample configuration files

	```
	CoreSummit/Staging.swift.xctemplate -> CoreSummit/Staging.swift
	CoreSummit/Production.swift.xctemplate -> CoreSummit/Production.swift
	OpenStack Summit/AppSecrets.swift.xctemplate -> OpenStack Summit/AppSecrets.swift
	```

3. Generate .entitlements out of sample entitlements files

	```
	Debug.entitlements.xctemplate -> Debug.entitlements
	Beta.entitlements.xctemplate -> Beta.entitlements
	Release.entitlements.xctemplate -> Release.entitlements
	OpenStackSummitTV.entitlements.xctemplate -> OpenStackSummitTV.entitlements
	OpenStackSummitTVService.entitlements.xctemplate -> OpenStackSummitTVService.entitlements
	```

4. Add Firebase configuration files

	```
	OpenStack Summit/Debug/GoogleService-Info.plist
	OpenStack Summit/Beta/GoogleService-Info.plist
	OpenStack Summit/Release/GoogleService-Info.plist
	```

5. Compile and run
