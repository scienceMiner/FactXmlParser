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
        
        
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            if let configURL = Bundle.module.url(forResource: "data2", withExtension: "xml") {
                print ( "does this work " )
                
                print(configURL.absoluteString)
                
                do {
                 // Get the saved data
                 let savedData = try Data(contentsOf: configURL)
                 // Convert the data back into a string
                 if let savedString = String(data: savedData, encoding: .utf8) {
                    print(savedString)
                    let newString = savedString.replacingOccurrences(of: "&", with: " and ", options: .literal, range: nil)
                    print(newString)
                    
                 }
                } catch {
                 // Catch any errors
                    print("Unable to read file " )
                }
                
                // did not like the race 
                let t1 = FactXmlParserAction( tagName: "entry" )

                t1.loadXml( urlPath : configURL )
            }
            else {
                print ( "module bundle NO GOOD  " )
            }
         //   XCTAssertEqual(FactXmlParser().text, "Hello, World!")
         //   let testBundle = Bundle(for: type(of: self))
             
            

        }
    }
