//
//  main.swift
//  XmlDiaryParser2
//
//  Created by Ethan Collopy on 21/07/2021.
//

import Foundation
import os
import os.log
import XMLParsing

                
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
    
    var journal: Journal = Journal(factArray: [])
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
            //print(" book parser \(attributeDict["id"]! as NSObject)" )
            bookTitle = String()
            bookAuthor = String()
            entryData = String()
        }
        
        
        self.elementName = elementName
    }

    // 2
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("FactParser::END ELEMENT for \(elementName) ")

        if elementName == "entry" {
            
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
            print("Appending fact to Facts \(item)")
            facts.append(book)
        }
        
        if elementName == "catalog" {
            print(" ElementName is CATALOG ")
            journal.entry = facts
        }
    }

    // 3
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if (!data.isEmpty) {
            print(" value: \(self.elementName) ")
            print(" data  \(data) ")
            if self.elementName == "entry" {
                entryData += data
            }
            if self.elementName == "fact" {
                entryData += data
            }
            if self.elementName == "title" {
                bookTitle += data
            } else if self.elementName == "author" {
                bookAuthor += data
            }
        }
    }
    
    public func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    // SAME AS SAVE
    public func encodeJournalToFile(facts: Journal, configURLNew: URL ) {
        let enc1 = XMLEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        enc1.dateEncodingStrategy = .formatted(dateFormatter)
        
        guard let returnData = try? enc1.encode(facts, withRootKey: "journal")
        else {
            fatalError("Error encoding data")
        }
        
        do {
                try returnData.write(to: configURLNew)
                print(" File NOW saved: \(configURLNew.absoluteURL) ")
        }
        catch {
                print("Unable to read file " )
                fatalError("Can't write to file")
        }
    }
    
    public func save(facts: Journal, configURL: URL) {
  //      DispatchQueue.global(qos: .background).async {
            let encoder = XMLEncoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            
            // ENCODE TO XML DATA
            guard let factData = try? encoder.encode(facts, withRootKey: "journal" )
            else {
                    fatalError("Error encoding data")
                }
        
            for fact in journal.entry {
                print("\(fact.date) wrote \(fact.fact) in list \(fact.iden) ")
            }
            // WRITE XML TO FILE
            do {
                try factData.write(to: configURL)
                print(" File saved: \(configURL.absoluteURL) ")
            } catch {
                // Catch any errors
                print(error.localizedDescription)
                fatalError("Can't write to file")
                
            }
            
            // DATA HAS BEEN WRITTING to configURL
                
          //  let decodedJournal = decodeXMLFromFile(configURL: configURL)
                
          //  let dateNewURL = getDocumentsDirectory().appendingPathComponent("dataNew.xml")
                
          //  encodeJournalToFile(facts: decodedJournal, configURLNew: dateNewURL )
        
    }
    
    public func getDataString(retrievedData: Data) -> String {
        var retrievedString = String()
        retrievedString = String(data: retrievedData, encoding: .utf8)!
        //let newString = retrievedString.replacingOccurrences(of: "&", with: " //and ", options: .literal, range: nil)
        return retrievedString
    }
    
    public func decodeXMLFromFile(configURL: URL) -> Journal {
        
        var decodedJournalData = Journal(factArray: [])
        
        do{
            
            let retrievedData = try Data(contentsOf: configURL)
        
            print(getDataString(retrievedData: retrievedData))
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let decoder = XMLDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            decodedJournalData = try decoder.decode(Journal.self, from: retrievedData)
            

        }
        catch {
            // Catch any errors
            print(error.localizedDescription)
            fatalError("Can't write to file")
            
        }
        
        return decodedJournalData
    
    }
    
    public func loadXml(urlPath : URL) -> [Fact] {
        
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
        
        if let parser = XMLParser(contentsOf: urlPath ) {
            
            print(" loadXml::attempt to parse " )
            print( self.elementName )
                    parser.delegate = self
                    parser.parse()
            print(" parse complete ")
        
        }
        else {
            print(" PARSER not assigned, update urlPath ")
        }
            
        
        return facts
    }

    public func filter(input: String) -> String {
        
        let newString = input.replacingOccurrences(of: "&", with: " and ", options: .literal, range: nil)
        
        return newString
        
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

    @main
    struct App {
        static func main() {
            print("Starting.")
        }
    }
    
    

