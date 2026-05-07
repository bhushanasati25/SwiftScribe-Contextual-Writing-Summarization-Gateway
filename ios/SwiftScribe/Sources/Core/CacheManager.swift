import Foundation
import UIKit

class CacheManager {
    static let shared = CacheManager()
    
    // Using NSCache for automatic memory management (ARC compliant)
    private let cache = NSCache<NSString, NSString>()
    
    private init() {
        cache.countLimit = 100 // Maximum number of items
        cache.totalCostLimit = 1024 * 1024 * 10 // 10MB limit
        
        // Observe memory warnings to clear cache if needed
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        print("Memory warning received, clearing cache.")
        cache.removeAllObjects()
    }
    
    func set(_ value: String, for key: String) {
        cache.setObject(value as NSString, forKey: key as NSString)
    }
    
    func get(for key: String) -> String? {
        return cache.object(forKey: key as NSString) as String?
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
