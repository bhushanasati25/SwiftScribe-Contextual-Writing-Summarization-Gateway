import XCTest
@testable import SwiftScribe

final class CacheManagerTests: XCTestCase {
    
    func testCacheSetAndGet() {
        let cache = CacheManager.shared
        let key = "testKey"
        let value = "testValue"
        
        cache.set(value, for: key)
        let retrievedValue = cache.get(for: key)
        
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testCacheUpdate() {
        let cache = CacheManager.shared
        let key = "testKey"
        let initialValue = "initial"
        let updatedValue = "updated"
        
        cache.set(initialValue, for: key)
        cache.set(updatedValue, for: key)
        
        XCTAssertEqual(cache.get(for: key), updatedValue)
    }
}
