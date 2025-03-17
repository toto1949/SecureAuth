//
//  BiometricAuthSDK.swift
//  SecureAuth
//
//  Created by Taooufiq El moutaoouakil on 3/16/25.
//

import Foundation
import UIKit

public class BiometricAuthSDK {
    public struct AuthToken {
        public let userId: String
        public let deviceId: String
        public let issuedAt: Date
        public let expiresAt: Date
        public let rawValue: String

        public var isValid: Bool {
            return Date() < expiresAt
        }
    }

    public init() {}

    public func generateToken() -> AuthToken? {
        let userId = "user_\(UUID().uuidString.prefix(8))"
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
        let issuedAt = Date()
        let expiresAt = Calendar.current.date(byAdding: .minute, value: 10, to: issuedAt) ?? issuedAt

        let tokenDict: [String: Any] = [
            "userId": userId,
            "deviceId": deviceId,
            "issuedAt": Int(issuedAt.timeIntervalSince1970),
            "expiryDate": Int(expiresAt.timeIntervalSince1970)
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: tokenDict),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return AuthToken(userId: userId, deviceId: deviceId, issuedAt: issuedAt, expiresAt: expiresAt, rawValue: jsonString)
    }
}

