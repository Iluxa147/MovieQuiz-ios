import XCTest

@testable import MovieQuiz

class ArrayTests : XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let val = array[safe: 2]
        
        // Then
        XCTAssertNotNil(val)
        XCTAssertEqual(val, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
        
        // When
        let val = array[safe: 22]
        
        // Then
        XCTAssertNil(val)
    }
}
