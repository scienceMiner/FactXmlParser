//
//  Fact.swift
//  XMLDiaryParser
//
//  Created by Ethan Collopy on 28/06/2021.
//  Copyright © 2021 Ethan Collopy. All rights reserved.
//

import Foundation
import XMLParsing

public struct Fact : Codable {
    
    var iden: Int
    var fact: String
    var date: Date                          
   // var eventItemList: [EventItem]
    
    public init(details: [String: Any]) {
        iden = details["_id"] as? Int ?? 0
        fact = details["text"] as? String ?? ""
        date = Date()
    //    eventItemList = []
    }
    
    public init(iden: Int, fact: String, date: Date ) {
        self.iden = iden
        self.fact = fact
        self.date = date
    //    self.eventItemList = []
    }
    
    public init(iden: Int, fact: String, date: Date , eiList: [EventItem]) {
        self.iden = iden
        self.fact = fact
        self.date = date
    //    self.eventItemList = eiList
    }
    
    
    enum CodingKeys: String, CodingKey {
        case iden = "iden"
        case fact = "fact"
        case date = "entry_date"
        //case eventItemList = "eventItemList"
       
    }
    
}

public struct Journal : Codable {
    
    var entry: [Fact]
    
    public init(factArray: [Fact] ) {
        entry = factArray
    }
    
    enum CodingKeys: String, CodingKey {
        case entry = "entry"
        
    }
}




public struct EventItem : Codable {
    
    var type: EventType
    var eventDetail: String = ""
    
    enum EventType: String, Codable, CaseIterable {
        
        case event = "Event"
        case cinema = "Cinema"
        case meal = "Restaurant"
        case sport = "Sport"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let status = try? container.decode(String.self)
            
            switch status {
                case "Event": self = .event
                case "Cinema": self = .cinema
                case "Restaurant": self = .meal
                case "Sport": self = .sport
                default: self = .event
            }
        }
        
    }
    
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case eventDetail = "eventDetail"
        
    }
    
}


