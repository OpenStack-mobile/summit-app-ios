# OpenStack Foundation Summit App

The official app for the OpenStack Summit. ([iTunes](https://itunes.apple.com/us/app/openstack-foundation-summit/id1071261846?mt=8))

Supports iOS, watchOS and tvOS.

## Setup

1. Fetch [Carthage](https://github.com/Carthage/Carthage) dependencies.

	```
	carthage bootstrap
	```
2. Download [Google Maps SDK](https://www.gstatic.com/cpdc/aa3052925ceeea2d-GoogleMaps-1.13.2.tar.gz), [Fabric](https://kit-downloads.fabric.io/cocoapods/fabric/1.6.9/fabric.zip), [Crashlytics](https://kit-downloads.fabric.io/cocoapods/crashlytics/3.8.1/crashlytics.zip) and copy to `Vendor` folder.

3. Generate .swift out of sample configuration files

	```
	CoreSummit/Staging.swift.xctemplate -> CoreSummit/Staging.swift
	CoreSummit/Production.swift.xctemplate -> CoreSummit/Production.swift
	OpenStack Summit/AppConsumerKey.swift.xctemplate -> OpenStack Summit/AppConsumerKey.swift
	OpenStack Summit/FabricInfoPlist.swift.xctemplate -> OpenStack Summit/FabricInfoPlist.swift
	```

3. Generate .entitlements out of sample entitlements files

	```
	Debug.entitlements.xctemplate -> Debug.entitlements
	Beta.entitlements.xctemplate -> Beta.entitlements
	Release.entitlements.xctemplate -> Release.entitlements
	```
4. Compile and run
