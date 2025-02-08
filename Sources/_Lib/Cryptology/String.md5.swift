//
//  String.md5.swift
//  BotsiSDK
//
//  Created by Aleksei Valiano on 27.10.2023
//

import CommonCrypto
import Foundation

extension String {
    var md5: [UInt8] {
        let data = Data(utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }

        return hash
    }
}

extension [UInt8] {
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
