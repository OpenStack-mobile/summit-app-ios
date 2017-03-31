//
//  Person.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public protocol Person: Named {
    
    var firstName: String { get }
    
    var lastName: String { get }
        
    var pictureURL: String { get }
    
    var title: String? { get }
    
    var twitter: String? { get }
    
    var irc: String? { get }
    
    var linkedIn: String? { get }
    
    var biography: String? { get }
}

// MARK: - Named

public extension Person {
    
    var name: String { return firstName + " " + lastName }
    
    /// Generate an uppercase letter to use as an address book section derived from the person's name.
    var addressBookSectionName: String {
        
        let unknownLetter = "#"
        
        guard let firstLetter = self.name.characters.first
            else { return unknownLetter }
        
        let uppercaseLetter = String(firstLetter).uppercaseString
        
        return Self.addressBookSections.contains(uppercaseLetter) ? uppercaseLetter : unknownLetter
    }
    
    static var addressBookSections: [String] {
        
        return ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    }
}
