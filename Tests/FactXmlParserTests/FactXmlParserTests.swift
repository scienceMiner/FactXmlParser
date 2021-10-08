    import XCTest
    @testable import FactXmlParserAction

    
    @available(macOS 11.0, *)
    final class FactXmlParserTests: XCTestCase {
        
        static func getFile(_ name: String, withExtension: String) -> Data? {
            guard let url = Bundle(for: Self.self)
                    .url(forResource: name, withExtension: withExtension) else { return nil }
            guard let data = try? Data(contentsOf: url) else { return nil }
            return data
        }
        
        func getDocumentsDirectory() -> URL {
            // find all possible documents directories for this user
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

            // just send back the first one, which ought to be the only one
            return paths[0]
        }
        
        func testExample() {
            
            if let configURL = Bundle.module.url(forResource: "data2", withExtension: "xml") {
                print(configURL.absoluteString)
                
                do {
                 // Get the saved data
                 let savedData = try Data(contentsOf: configURL)
                 // Convert the data back into a string
                 if let savedString = String(data: savedData, encoding: .utf8) {
                    let newString = savedString.replacingOccurrences(of: "&", with: " and ", options: .literal, range: nil)
                    print(newString)
                    
                 }
                } catch {
                 // Catch any errors
                    print("Unable to read file " )
                }
                
                // did not like the race 
                let t1 = FactXmlParserAction( tagName: "entry" )

                var factArray = [Fact]()
                
                factArray = t1.loadXml( urlPath : configURL )
                
                let journal = Journal(factArray: factArray)
                for fact in factArray {
                    print("\(fact.date) wrote \(fact.fact) in list \(fact.iden) ")
                }
                
                print(getDocumentsDirectory())
                
                let url = self.getDocumentsDirectory().appendingPathComponent("catalog.xml")
                
                t1.save(facts:journal, configURL: url)
                
            
            }
            else {
                print ( "module bundle NO GOOD  " )
            }

        }
        
        
        func testDecodeFromEncodedXML() {
            
            let t1 = FactXmlParserAction( tagName: "entry" )

            //let dataNewURL = self.getDocumentsDirectory().appendingPathComponent("dataNew.xml")
            if let dataNewURL = Bundle.module.url(forResource: "dataNew", withExtension: "xml")
            {
                let decodedJournal = t1.decodeXMLFromFile(configURL: dataNewURL)
                for fact in decodedJournal.entry {
                        print("\(fact.date) :: \(fact.iden) DETAIL: \(fact.fact) ")
                }
            }
            else {
                print(" module not found ")
            }
        }
        
        func testSaveXML() {
            
            let t1 = FactXmlParserAction( tagName: "entry" )

            let dataNewURL = self.getDocumentsDirectory().appendingPathComponent("dataNew.xml")
            
            let decodedJournal = t1.decodeXMLFromFile(configURL: dataNewURL)
            
            for fact in decodedJournal.entry {
                        print("\(fact.date) :: \(fact.iden) DETAIL: \(fact.fact) ")
            }
                
            t1.save(facts: decodedJournal, configURL: dataNewURL )
            
        }
        
        
    }
