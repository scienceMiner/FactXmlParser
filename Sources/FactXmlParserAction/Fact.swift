//
//  Fact.swift
//  XMLDiaryParser
//
//  Created by Ethan Collopy on 28/06/2021.
//  Copyright © 2021 Ethan Collopy. All rights reserved.
//

import Foundation


public struct Fact {
    var iden: Int
    var fact: String
    var date: Date                          
    
    public init(details: [String: Any]) {
        iden = details["_id"] as? Int ?? 0
        fact = details["text"] as? String ?? ""
        date = Date()
    }
    
    public init(iden: Int, fact: String, date: Date ) {
        self.iden = iden
        self.fact = fact
        self.date = date
    }
    
    
    
}
