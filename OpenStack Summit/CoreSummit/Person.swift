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
        
    var picture: URL { get }
    
    var title: String? { get }
    
    var twitter: String? { get }
    
    var irc: String? { get }
    
    var linkedIn: String? { get }
    
    var biography: String? { get }
}

// MARK: - Named

public extension Person {
    
    var name: String { return firstName + " " + lastName }
}

// MARK: - Address Book 

/// Type for organizing `Person` entities into an address book.
public struct AddressBook {
    
    /// All the sections in the address book.
    public static let sections = ["#","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    /// Generate an uppercase letter to use as an address book section derived from the person's name.
    public static func section<T: Person>(for person: T) -> String {
        
        let unknownLetter = sections[0] // "#"
        
        guard let firstLetter = person.name.characters.first
            else { return unknownLetter }
        
        let uppercaseLetter = String(firstLetter).uppercased()
        
        return sections.contains(uppercaseLetter) ? uppercaseLetter : unknownLetter
    }
}
