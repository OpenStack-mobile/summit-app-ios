//
//  ListJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

enum PageJSONKey: String {
    
    case current_page, total, last_page, data, per_page
}

extension Page: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let currentPage = JSONObject[PageJSONKey.current_page.rawValue]?.rawValue as? Int,
            let total = JSONObject[PageJSONKey.total.rawValue]?.rawValue as? Int,
            let lastPage = JSONObject[PageJSONKey.last_page.rawValue]?.rawValue as? Int,
            let perPage = JSONObject[PageJSONKey.per_page.rawValue]?.rawValue as? Int,
            let dataArray = JSONObject[PageJSONKey.data.rawValue]?.arrayValue,
            let items = Item.fromJSON(dataArray)
            else { return nil }
        
        self.currentPage = currentPage
        self.total = total
        self.lastPage = lastPage
        self.perPage = perPage
        self.items = items
    }
}