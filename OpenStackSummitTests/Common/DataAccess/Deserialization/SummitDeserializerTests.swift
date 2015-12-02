//
//  SummitDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class SummitDeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Deserialize_ValidJSON_ReturnsCorrectSummitInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":5,\"name\":\"Tokyo\",\"start_date\":1445904000,\"end_date\":1446163200,\"time_zone\":{\"country_code\":\"JP\",\"latitude\":35.65444,\"longitude\":139.74472,\"comments\":\"\",\"name\":\"Asia\\/Tokyo\",\"offset\":32400},\"summit_types\":[{\"id\":1,\"name\":\"Main Summit\"},{\"id\":2,\"name\":\"Design Summit\"}],\"ticket_types\":[{\"id\":1,\"name\":\"Early Bird Full Access Pass\",\"description\":null,\"allowed_summit_types\":[]},{\"id\":2,\"name\":\"Full Access Pass\",\"description\":null,\"allowed_summit_types\":[]}],\"locations\":[{\"id\":\"17\",\"name\":\"Haneda Airport\",\"description\":null,\"class_name\":\"SummitAirport\",\"location_type\":\"None\",\"address_1\":\"Hanedakuko<BR>Ota, Tokyo 144-0041, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.79\",\"lat\":\"35.55\"},{\"id\":\"18\",\"name\":\"Narita International Airport\",\"description\":null,\"class_name\":\"SummitAirport\",\"location_type\":\"None\",\"address_1\":\"1-1 Furugome, Narita-shi<BR>Chiba-ken 282-0004, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"140.38\",\"lat\":\"35.77\"},{\"id\":\"19\",\"name\":\"Grand Prince International Convention Center & Hotels\",\"description\":null,\"class_name\":\"SummitVenue\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa\\r\\nMinato, Tokyo 108-8612, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\",\"rooms\":[]},{\"id\":\"20\",\"name\":\"The Prince Sakura Tower Tokyo\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.74\",\"lat\":\"35.63\"},{\"id\":\"21\",\"name\":\"Grand Prince Hotel New Takanawa\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":\"22\",\"name\":\"Grand Prince Hotel Takanawa\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":\"23\",\"name\":\"Shinagawa Prince Hotel\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"10-30 Takanawa 4-chome, Minato-ku<br>\\r\\nTokyo, 108-8611 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.74\",\"lat\":\"35.63\"}],\"event_types\":[{\"id\":1,\"name\":\"Reception\"},{\"id\":2,\"name\":\"Main Conference\"},{\"id\":3,\"name\":\"Presentation\"}],\"sponsors\":[],\"speakers\":[{\"id\":173,\"first_name\":\"Michael\",\"last_name\":\"Johnson\",\"title\":\"Software Engineer\",\"bio\":null,\"irc\":null,\"twitter\":null,\"member_id\":\"0\"},{\"id\":\"1761\",\"first_name\":\"Alessandro\",\"last_name\":\"Pilotti\",\"title\":\"CEO\",\"bio\":\"<p class=\\\"p1\\\"><span class=\\\"s1\\\">Alessandro Pilotti is the CEO of Cloudbase Solutions, a company focused on cloud computing interoperabilstart_dateity and the main contributor&nbsp;of all the OpenStack Windows and Hyper-V components in Nova, Neutron, Cinder, Ceilometer and Heat since the Folsom release. Alessandro lives in Timisoara, Romania. When not hacking or travelling, he is flying with his paraglider into old fashioned clouds.<\\/span><\\/p>\\r\\n<p class=\\\"p1\\\">&nbsp;<\\/p>\",\"irc\":\"alexpilotti\",\"twitter\":\"@cloudbaseit\",\"member_id\":\"5922\"},{\"id\":\"1861\",\"first_name\":\"Peter\",\"last_name\":\"Pouliot\",\"title\":\"Microsoft OpenStack Evangelist\",\"bio\":null,\"irc\":null,\"twitter\":null,\"member_id\":\"311\"}],\"tracks\":[{\"id\":1,\"name\":\"Cloudfunding: Startups and Capital\"},{\"id\":2,\"name\":\"Enterprise IT Strategies\"},{\"id\":3,\"name\":\"Telco Strategies\"},{\"id\":4,\"name\":\"How to Contribute\"},{\"id\":5,\"name\":\"Planning Your OpenStack Cloud\"},{\"id\":6,\"name\":\"Products, Tools, & Services\"},{\"id\":7,\"name\":\"User Stories\"},{\"id\":8,\"name\":\"Community\"},{\"id\":9,\"name\":\"Related OSS Projects\"},{\"id\":\"11\",\"name\":\"Cloud Security\"},{\"id\":\"12\",\"name\":\"Compute\"},{\"id\":\"13\",\"name\":\"Storage\"},{\"id\":\"14\",\"name\":\"Networking\"},{\"id\":\"15\",\"name\":\"Public & Hybrid Clouds\"},{\"id\":16,\"name\":\"Hands-on Labs\"},{\"id\":\"17\",\"name\":\"Targeting Apps for OpenStack Clouds\",\"allow_feedback\": true},{\"id\":\"18\",\"name\":\"Operations\"},{\"id\":19,\"name\":\"Containers\"}],\"schedule\":[{\"id\":\"5290\",\"title\":\"Windows in OpenStack\",\"description\":\"<p>OpenStack is getting big in the enterprise, which is traditionally very Microsoft centeric. This session will show you everything you need to know about Windows in OpenStack!<\\/p>\\n<p>To begin with we will show how to provision Windows images for OpenStack, including Windows Server 2012 R2, Windows 7, 8.1 and the brand new Windows Server 2016 Nano Server for KVM, Hyper-V and ESXi Nova hosts.<\\/p>\\n<p>Next, we will show how to deploy Windows workloads with Active Directory, SQL Server, SharePoint, Exchange using Heat templates, Juju, Puppet and more.<\\/p>\\n<p>Last but not least, we'll talk about Active Directory integration in Keystone, Hyper-V deployment and Windows bare metal support in Ironic and MaaS. <\\/p>\\n<p>The session will give you a comprehensive view on how well OpenStack and Windows can be integrated, along with a great interoperability story with Linux workloads.<\\/p>\",\"start_date\":1446026400,\"end_date\":1446029100,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":\"2\",\"level\":\"Beginner\",\"summit_types\":[1],\"sponsors\":[],\"speakers\":[1761,1861],\"allow_feedback\": true},{\"id\":6762,\"title\":\"Registration Check-In\",\"description\":\"<p>a description<\\/p>\",\"start_date\":1445929200,\"end_date\":1445936400,\"location_id\":19,\"type_id\":1,\"class_name\":\"SummitEvent\",\"summit_types\":[],\"sponsors\":[],\"allow_feedback\": true},{\"id\":\"6763\",\"title\":\"A Day in the Life of an Openstack & Cloud Architect\",\"description\":\"<p>a description<\\/p>\",\"start_date\":1445943600,\"end_date\":1445946900,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":\"1\",\"level\":\"Beginner\",\"summit_types\":[1],\"sponsors\":[],\"speakers\":[173],\"allow_feedback\": true}]}"
        
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        
        //Act
        let summit = try! deserializer.deserialize(jsonObject) as! Summit
        
        //Assert
        XCTAssertEqual(5,summit.id)
        XCTAssertEqual("Tokyo",summit.name)
        XCTAssertEqual(1446026400,summit.startDate.timeIntervalSince1970)
        XCTAssertEqual(1445946900,summit.endDate.timeIntervalSince1970)
        XCTAssertEqual("Asia/Tokyo",summit.timeZone)
        XCTAssertEqual(2,summit.types.count)
        XCTAssertEqual(1,summit.venues.count)
        XCTAssertEqual(3,summit.events.count)
        XCTAssertEqual(2,summit.ticketTypes.count)
    }
    
    func test_Deserialize_ValidJSON_ReturnsInstanceWithCorrectVenues() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":5,\"name\":\"Tokyo\",\"start_date\":1445904000,\"end_date\":1446163200,\"time_zone\":{\"country_code\":\"JP\",\"latitude\":35.65444,\"longitude\":139.74472,\"comments\":\"\",\"name\":\"Asia/Tokyo\",\"offset\":32400},\"tracks\":[],\"speakers\":[],\"schedule\":[{\"id\":\"5290\",\"title\":\"Windows in OpenStack\",\"description\":\"<p>OpenStack is getting big in the enterprise, which is traditionally very Microsoft centeric. This session will show you everything you need to know about Windows in OpenStack!<\\/p>\\n<p>To begin with we will show how to provision Windows images for OpenStack, including Windows Server 2012 R2, Windows 7, 8.1 and the brand new Windows Server 2016 Nano Server for KVM, Hyper-V and ESXi Nova hosts.<\\/p>\\n<p>Next, we will show how to deploy Windows workloads with Active Directory, SQL Server, SharePoint, Exchange using Heat templates, Juju, Puppet and more.<\\/p>\\n<p>Last but not least, we'll talk about Active Directory integration in Keystone, Hyper-V deployment and Windows bare metal support in Ironic and MaaS. <\\/p>\\n<p>The session will give you a comprehensive view on how well OpenStack and Windows can be integrated, along with a great interoperability story with Linux workloads.<\\/p>\",\"start_date\":1446026400,\"end_date\":1446029100,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":\"2\",\"level\":\"Beginner\",\"summit_types\":[1],\"sponsors\":[],\"speakers\":[],\"allow_feedback\": true},{\"id\":6762,\"title\":\"Registration Check-In\",\"description\":\"<p>a description<\\/p>\",\"start_date\":1445929200,\"end_date\":1445936400,\"location_id\":19,\"type_id\":1,\"class_name\":\"SummitEvent\",\"summit_types\":[],\"sponsors\":[],\"allow_feedback\": true},{\"id\":\"6763\",\"title\":\"A Day in the Life of an Openstack & Cloud Architect\",\"description\":\"<p>a description<\\/p>\",\"start_date\":1445943600,\"end_date\":1445946900,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":\"1\",\"level\":\"Beginner\",\"summit_types\":[1],\"sponsors\":[],\"speakers\":[],\"allow_feedback\": true}],\"summit_types\":[{\"id\":1,\"name\":\"Main Conference\"},{\"id\":2,\"name\":\"Design Summit + Main Conference\"}],\"ticket_types\":[{\"id\":1,\"name\":\"Early Bird Full Access Pass\",\"description\":\"Includes lunch. Allows access to everything at the Summit.\",\"allowed_summit_types\":[1,2]},{\"id\":2,\"name\":\"Full Access Pass\",\"description\":\"Includes lunch. Allows access to everything at the Summit.\",\"allowed_summit_types\":[1,2]},{\"id\":3,\"name\":\"Full Access Pass -\",\"description\":\"Includes lunch. Allows access to everything at the Summit.\",\"allowed_summit_types\":[1,2]}],\"locations\":[{\"id\":17,\"name\":\"Haneda Airport\",\"description\":null,\"class_name\":\"SummitAirport\",\"location_type\":\"External\",\"address_1\":\"Hanedakuko<BR>Ota, Tokyo 144-0041, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.79\",\"lat\":\"35.55\"},{\"id\":18,\"name\":\"Narita International Airport\",\"description\":null,\"class_name\":\"SummitAirport\",\"location_type\":\"External\",\"address_1\":\"1-1 Furugome, Narita-shi<BR>Chiba-ken 282-0004, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"140.38\",\"lat\":\"35.77\"},{\"id\":19,\"name\":\"Grand Prince International Convention Center & Hotels\",\"description\":null,\"class_name\":\"SummitVenue\",\"location_type\":\"Internal\",\"address_1\":\"3-13-1 Takanawa\\r\\nMinato, Tokyo 108-8612, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":20,\"name\":\"The Prince Sakura Tower Tokyo\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"External\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.74\",\"lat\":\"35.63\"},{\"id\":21,\"name\":\"Grand Prince Hotel New Takanawa\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"External\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":22,\"name\":\"Grand Prince Hotel Takanawa\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"External\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":23,\"name\":\"Shinagawa Prince Hotel\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"External\",\"address_1\":\"10-30 Takanawa 4-chome, Minato-ku<br>\\r\\nTokyo, 108-8611 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.74\",\"lat\":\"35.63\"},{\"id\":24,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Kougyoku\",\"description\":null,\"Capacity\":null},{\"id\":25,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Gyoko\",\"description\":null,\"Capacity\":null},{\"id\":26,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Kyokko\",\"description\":null,\"Capacity\":null},{\"id\":27,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Wakaba\",\"description\":null,\"Capacity\":null},{\"id\":28,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Seigyoku\",\"description\":null,\"Capacity\":null},{\"id\":29,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Sakura Lower Level N-1 and N-2\",\"description\":null,\"Capacity\":null},{\"id\":30,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Hakugyoku\",\"description\":null,\"Capacity\":null},{\"id\":31,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Tempyo (New Takanawa)\",\"description\":null,\"Capacity\":null},{\"id\":32,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Matsuba\",\"description\":null,\"Capacity\":null},{\"id\":33,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Sakura Lower Level S-1 and S-2\",\"description\":null,\"Capacity\":null},{\"id\":34,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Outei\",\"description\":null,\"Capacity\":null},{\"id\":35,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Ogyoku\",\"description\":null,\"Capacity\":null},{\"id\":36,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Hokushin\",\"description\":null,\"Capacity\":null},{\"id\":37,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Heian (New Takanawa)\",\"description\":null,\"Capacity\":null},{\"id\":38,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Expo Hall (Marketplace Theater)\",\"description\":null,\"Capacity\":null},{\"id\":39,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Aoba\",\"description\":null,\"Capacity\":null},{\"id\":40,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Zuiko\",\"description\":null,\"Capacity\":null},{\"id\":41,\"venue_id\":19,\"class_name\":\"SummitVenueRoom\",\"name\":\"Marketplace Expo Hall\",\"description\":null,\"Capacity\":null}],\"event_types\":[{\"id\":1,\"name\":\"Presentation\"},{\"id\":2,\"name\":\"Keynotes\"},{\"id\":3,\"name\":\"Hand-on Labs\"},{\"id\":4,\"name\":\"Lunch & Breaks\"},{\"id\":5,\"name\":\"Evening Events\"},{\"id\":6,\"name\":\"Sponsor Sessions\"},{\"id\":7,\"name\":\"User Stories\"},{\"id\":8,\"name\":\"Collaboration Day\"},{\"id\":9,\"name\":\"Registration Check-In\"},{\"id\":10,\"name\":\"Sponsor Demos\"},{\"id\":11,\"name\":\"Japanese Language\"},{\"id\":12,\"name\":\"Working Groups\"},{\"id\":13,\"name\":\"Community\"}],\"sponsors\":[{\"id\":59,\"name\":\"Cisco\"},{\"id\":227,\"name\":\"Red Hat, Inc.\"},{\"id\":806,\"name\":\"ITOCHU\"},{\"id\":403,\"name\":\"Fujitsu\"}]}"
        
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        
        //Act
        let summit = try! deserializer.deserialize(jsonObject) as! Summit
        
        //Assert
        XCTAssertEqual(1,summit.venues.count)
        XCTAssertEqual(18,summit.venues.first?.venueRooms.count)
    }
    
    func test_deserialize_jsonWithAllManfatoryFieldsMissed_throwsBadFormatException() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{}"
        let expectedExceptionCount = 1
        var exceptionCount = 0
        var errorMessage = ""
        
        //Act
        do {
            try deserializer.deserialize(json) as! Summit
        }
        catch DeserializerError.BadFormat(let em) {
            exceptionCount++
            errorMessage = em
        }
        catch {
            
        }
        
        //Assert
        XCTAssertEqual(expectedExceptionCount, exceptionCount)
        XCTAssertNotNil(errorMessage.rangeOfString("Following fields are missed: id, name, start_date, end_date, time_zone, sponsors, summit_types, ticket_types, event_types, tracks, locations, speakers, schedule"))
    }
}