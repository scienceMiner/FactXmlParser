//
//  main.swift
//  XmlDiaryParser2
//
//  Created by Ethan Collopy on 21/07/2021.
//

import Foundation
import os
import os.log

protocol ParserDelegate : XMLParserDelegate {
    
    var delegateStack: ParserDelegateStack? { get set }
  
}

class ParserDelegateStack {
    
    private var parsers: [ParserDelegate] = []
    private let xmlParser: XMLParser
    
    init(xmlParser: XMLParser) {
        self.xmlParser = xmlParser
    }

    func push(_ parser: ParserDelegate) {
        parser.delegateStack = self
        xmlParser.delegate = parser
        parsers.append(parser)
    }

    func pop() {
        parsers.removeLast()
        if let next = parsers.last {
            xmlParser.delegate = next
        //    next.didBecomeActive()
        } else {
            xmlParser.delegate = nil
        }
    }
    
}



@available(macOS 11.0, *)
public class FactXmlParserAction : NSObject, XMLParserDelegate {
    
    
    var facts: [Fact] = []
    var elementName: String = String()
    var bookTitle = String()
    var bookAuthor = String()
    var entryData = String()
    var item = Int()
    var day = Int()
    var mon = String()
    var year = Int()
    var parsedDate = Date()
    
    
    public var tagName: String = ""
    
    var delegateStack: ParserDelegateStack?
    
    public init( tagName: String ) {
        print(" init FactParser ")
        self.tagName = tagName
    }

    
    // 1
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("FactParser::START ELEMENT for \(elementName) ")

        
        if elementName == "entry" {
            item = Int(attributeDict["id"] ?? "0") ?? 0
            day = Int(attributeDict["day"] ?? "0") ?? 0
            year = Int(attributeDict["year"] ?? "0") ?? 0
            mon = attributeDict["mon"] ?? "1900"
            os_log(" book parser \(attributeDict["id"]! as NSObject)" )
            bookTitle = String()
            bookAuthor = String()
            entryData = String()
        }

        self.elementName = elementName
    }

    // 2
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        os_log("FactParser::END ELEMENT for \(elementName) ")

        if elementName == "entry" {
            //let book = Book(bookTitle: bookTitle, bookAuthor: bookAuthor , itemNum: item)
            
            var date = DateComponents()
            date.year = year
            date.month = convert(month: mon)
            date.day = day
            date.timeZone = TimeZone(abbreviation: "GMT")
            date.hour = 00
            date.minute = 00
            date.second = 00
            //let userCalendar = Calendar.current
            let parsedDate = Calendar.current.date(from: date)!
                        
            let book = Fact(iden: item, fact: entryData , date: parsedDate)
            facts.append(book)
        }
    }

    // 3
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            os_log(" value: \(self.elementName) ")
            os_log(" data  \(data) ")
            if self.elementName == "entry" {
                entryData += data
            }
            if self.elementName == "title" {
                bookTitle += data
            } else if self.elementName == "author" {
                bookAuthor += data
            }
        }
    }
    

    public func loadXml(urlPath : URL) {
        
        print(" loadXml enter ")
        do {
         // Get the saved data
         let savedData = try Data(contentsOf: urlPath)
         // Convert the data back into a string
         if let savedString = String(data: savedData, encoding: .utf8) {
            print(savedString)
         }
        } catch {
         // Catch any errors
            print("Unable to read file " )
        }
//        if let path = Bundle.main.url(forResource: "data", withExtension: "xml")
        // { }
        
        if let parser = XMLParser(contentsOf: urlPath ) {
             
        // let xmlData = bookXml.data(using: .utf8)!
        // let xmlParser = XMLParser(data: xmlData)
        // NOT USING: let delegateStack = ParserDelegateStack(xmlParser: xmlParser)
            print(" loadXml::attempt to parse " )
            print( self.elementName )
                    parser.delegate = self
                    parser.parse()
            print(" parse complete ")
        
        }
        else {
            print(" PARSER not assigned, update urlPath ")
        }
            
        for fact in facts {
            print("\(fact.date) wrote \(fact.fact) in list \(fact.iden) ")
        }
    }

    
    
    func convert(month: String) -> Int {
        if (month=="June") {
            return 6
        }
        else {
            return 3
        }
    }
    
}
