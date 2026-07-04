import Foundation

extension String {
    var stableHash: String {
        var hash: UInt32 = 5381
        for scalar in unicodeScalars {
            hash = (hash << 5) &+ hash &+ scalar.value
        }
        return String(format: "%08x", hash)
    }
}
