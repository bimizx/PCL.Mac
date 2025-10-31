//
//  AESUtil.swift
//  PCL.Mac
//
//  Created by 温迪 on 2025/10/22.
//

import Foundation
import CryptoKit

public class AESUtil {
    public static func encrypt(data: Data, key: String) throws -> Data {
        let keyData: Data = try key.data(using: .utf8).unwrap()
        
        let symmetricKey: SymmetricKey = SymmetricKey(data: keyData)
        let nonce: AES.GCM.Nonce = AES.GCM.Nonce()
        
        let sealedBox: AES.GCM.SealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)
        return nonce + sealedBox.ciphertext + sealedBox.tag
    }
    
    public static func decrypt(data: Data, key: String) throws -> Data {
        let keyData = try key.data(using: .utf8).unwrap()
        
        let nonce = data.prefix(12)
        let tag = data.suffix(16)
        let cipherText = data[12..<(data.count - 16)]
        let symmetricKey = SymmetricKey(data: keyData)
        
        let sealedBox = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: nonce),
            ciphertext: cipherText,
            tag: tag
        )
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }
    
    private init() {
    }
}
