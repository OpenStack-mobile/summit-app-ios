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
        let json = "{\"id\":\"5\",\"name\":\"Tokyo\",\"start_date\":1445904000,\"end_date\":1446163200,\"time_zone\":{\"country_code\":\"JP\",\"latitude\":35.65444,\"longitude\":139.74472,\"comments\":\"\",\"name\":\"Asia\\/Tokyo\",\"offset\":32400},\"summit_types\":[{\"id\":\"1\",\"type\":\"Main Summit\"},{\"id\":\"2\",\"type\":\"Design Summit\"}],\"ticket_types\":[{\"id\":\"1\",\"name\":\"Early Bird Full Access Pass\",\"description\":null,\"allowed_summit_types\":[]},{\"id\":\"2\",\"name\":\"Full Access Pass\",\"description\":null,\"allowed_summit_types\":[]}],\"locations\":[{\"id\":\"17\",\"name\":\"Haneda Airport\",\"description\":null,\"class_name\":\"SummitAirport\",\"location_type\":\"None\",\"address_1\":\"Hanedakuko<BR>Ota, Tokyo 144-0041, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.79\",\"lat\":\"35.55\"},{\"id\":\"18\",\"name\":\"Narita International Airport\",\"description\":null,\"class_name\":\"SummitAirport\",\"location_type\":\"None\",\"address_1\":\"1-1 Furugome, Narita-shi<BR>Chiba-ken 282-0004, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"140.38\",\"lat\":\"35.77\"},{\"id\":\"19\",\"name\":\"Grand Prince International Convention Center & Hotels\",\"description\":null,\"class_name\":\"SummitVenue\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa\\r\\nMinato, Tokyo 108-8612, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\",\"rooms\":[]},{\"id\":\"20\",\"name\":\"The Prince Sakura Tower Tokyo\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.74\",\"lat\":\"35.63\"},{\"id\":\"21\",\"name\":\"Grand Prince Hotel New Takanawa\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":\"22\",\"name\":\"Grand Prince Hotel Takanawa\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"3-13-1 Takanawa, Minato-ku<br>\\r\\nTokyo, 108-8612 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"},{\"id\":\"23\",\"name\":\"Shinagawa Prince Hotel\",\"description\":null,\"class_name\":\"SummitHotel\",\"location_type\":\"None\",\"address_1\":\"10-30 Takanawa 4-chome, Minato-ku<br>\\r\\nTokyo, 108-8611 Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.74\",\"lat\":\"35.63\"}],\"event_types\":[{\"id\":\"1\",\"type\":\"Reception\"},{\"id\":\"2\",\"type\":\"Main Conference\"},{\"id\":\"3\",\"type\":\"Presentation\"}],\"sponsors\":[],\"speakers\":[{\"id\":\"173\",\"first_name\":\"Michael\",\"last_name\":\"Johnson\",\"title\":\"Software Engineer\",\"bio\":null,\"irc\":null,\"twitter\":null,\"member_id\":\"0\"},{\"id\":\"1761\",\"first_name\":\"Alessandro\",\"last_name\":\"Pilotti\",\"title\":\"CEO\",\"bio\":\"<p class=\\\"p1\\\"><span class=\\\"s1\\\">Alessandro Pilotti is the CEO of Cloudbase Solutions, a company focused on cloud computing interoperability and the main contributor&nbsp;of all the OpenStack Windows and Hyper-V components in Nova, Neutron, Cinder, Ceilometer and Heat since the Folsom release. Alessandro lives in Timisoara, Romania. When not hacking or travelling, he is flying with his paraglider into old fashioned clouds.<\\/span><\\/p>\\r\\n<p class=\\\"p1\\\">&nbsp;<\\/p>\",\"irc\":\"alexpilotti\",\"twitter\":\"@cloudbaseit\",\"member_id\":\"5922\"},{\"id\":\"1861\",\"first_name\":\"Peter\",\"last_name\":\"Pouliot\",\"title\":\"Microsoft OpenStack Evangelist\",\"bio\":null,\"irc\":null,\"twitter\":null,\"member_id\":\"311\"}],\"tracks\":[{\"id\":\"1\",\"type\":\"Cloudfunding: Startups and Capital\"},{\"id\":\"2\",\"type\":\"Enterprise IT Strategies\"},{\"id\":\"3\",\"type\":\"Telco Strategies\"},{\"id\":\"4\",\"type\":\"How to Contribute\"},{\"id\":\"5\",\"type\":\"Planning Your OpenStack Cloud\"},{\"id\":\"6\",\"type\":\"Products, Tools, & Services\"},{\"id\":\"7\",\"type\":\"User Stories\"},{\"id\":\"8\",\"type\":\"Community\"},{\"id\":\"9\",\"type\":\"Related OSS Projects\"},{\"id\":\"11\",\"type\":\"Cloud Security\"},{\"id\":\"12\",\"type\":\"Compute\"},{\"id\":\"13\",\"type\":\"Storage\"},{\"id\":\"14\",\"type\":\"Networking\"},{\"id\":\"15\",\"type\":\"Public & Hybrid Clouds\"},{\"id\":\"16\",\"type\":\"Hands-on Labs\"},{\"id\":\"17\",\"type\":\"Targeting Apps for OpenStack Clouds\"},{\"id\":\"18\",\"type\":\"Operations\"},{\"id\":\"19\",\"type\":\"Containers\"}],\"schedule\":[{\"id\":\"5290\",\"title\":\"Windows in OpenStack\",\"description\":\"<p>OpenStack is getting big in the enterprise, which is traditionally very Microsoft centeric. This session will show you everything you need to know about Windows in OpenStack!<\\/p>\\n<p>To begin with we will show how to provision Windows images for OpenStack, including Windows Server 2012 R2, Windows 7, 8.1 and the brand new Windows Server 2016 Nano Server for KVM, Hyper-V and ESXi Nova hosts.<\\/p>\\n<p>Next, we will show how to deploy Windows workloads with Active Directory, SQL Server, SharePoint, Exchange using Heat templates, Juju, Puppet and more.<\\/p>\\n<p>Last but not least, we'll talk about Active Directory integration in Keystone, Hyper-V deployment and Windows bare metal support in Ironic and MaaS. <\\/p>\\n<p>The session will give you a comprehensive view on how well OpenStack and Windows can be integrated, along with a great interoperability story with Linux workloads.<\\/p>\",\"start_date\":1446026400,\"end_date\":1446029100,\"location_id\":\"19\",\"type_id\":\"3\",\"class_name\":\"Presentation\",\"track_id\":\"2\",\"level\":\"Beginner\",\"summit_types\":[\"1\"],\"sponsors\":[],\"speakers\":[\"1761\",\"1861\"]},{\"id\":\"6762\",\"title\":\"Registration Check-In\",\"description\":\"<p>a description<\\/p>\",\"start_date\":1445929200,\"end_date\":1445936400,\"location_id\":\"19\",\"type_id\":\"1\",\"class_name\":\"SummitEvent\",\"summit_types\":[],\"sponsors\":[]},{\"id\":\"6763\",\"title\":\"A Day in the Life of an Openstack & Cloud Architect\",\"description\":\"<p>a description<\\/p>\",\"start_date\":1445943600,\"end_date\":1445946900,\"location_id\":\"19\",\"type_id\":\"3\",\"class_name\":\"Presentation\",\"track_id\":\"1\",\"level\":\"Beginner\",\"summit_types\":[\"1\"],\"sponsors\":[],\"speakers\":[\"173\"]}]}"
        
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        
        //Act
        let summit = try! deserializer.deserialize(jsonObject) as! Summit
        
        //Assert
        XCTAssertEqual(5,summit.id)
        XCTAssertEqual("Tokyo",summit.name)
        XCTAssertEqual(1445904000,summit.startDate.timeIntervalSince1970)
        XCTAssertEqual(1446163200,summit.endDate.timeIntervalSince1970)
        XCTAssertEqual("Asia/Tokyo",summit.timeZone)
        XCTAssertEqual(2,summit.types.count)
        XCTAssertEqual(7,summit.venues.count)
        XCTAssertEqual(3,summit.events.count)
        XCTAssertEqual(2,summit.ticketTypes.count)
        XCTAssertEqual("Asia/Tokyo",summit.events[0].timeZone)
        XCTAssertEqual("Asia/Tokyo",summit.events[1].timeZone)
        XCTAssertEqual("Asia/Tokyo",summit.events[2].timeZone)
    }
}