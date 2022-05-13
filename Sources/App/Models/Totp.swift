//
//  Totp.swift
//  
//
//  Created by Короткий Егор on 26.04.2022.
//

import Foundation
import CryptoKit

final class Totp {

    func checkTotp(clientCode: String, user: User) -> Bool {
        guard let serverSecret = user.secret else {
            return false
        }

        let serverTotp = generateTotp(secret: Data(serverSecret.utf8))

        return clientCode == serverTotp
    }

    func generateTotp(secret: Data) -> String {
        let period = TimeInterval(30)
        let numbersCount = 6
        var counter = UInt64(Date().timeIntervalSince1970 / period).bigEndian

        let counterData = withUnsafeBytes(of: &counter) { Array($0) }
        let hash = HMAC<SHA256>.authenticationCode(for: counterData, using: SymmetricKey(data: secret))

        var truncatedHash = hash.withUnsafeBytes { ptr -> UInt32 in
            let offset = ptr[hash.byteCount - 1] & 0x0f

            let truncatedHashPtr = ptr.baseAddress! + Int(offset)
            return truncatedHashPtr.bindMemory(to: UInt32.self, capacity: 1).pointee
        }

        truncatedHash = UInt32(bigEndian: truncatedHash)
        truncatedHash = truncatedHash & 0x7fffffff
        truncatedHash = truncatedHash % UInt32(pow(10, Float(numbersCount)))

        let totp = String(format: "%0*u", numbersCount, truncatedHash)

        return totp
    }
}
