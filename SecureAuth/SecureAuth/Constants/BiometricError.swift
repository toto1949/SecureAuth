//
//  BiometricConstants.swift
//  SecureAuth
//
//  Created by Taooufiq El moutaoouakil on 3/16/25.
//

import Foundation

public enum BiometricError: Error {
    case authenticationFailed
    case biometryNotAvailable
    case userCancelled
    case systemError(Error)
    
    var localizedDescription: String {
        switch self {
        case .authenticationFailed:
            return "Authentication failed"
        case .biometryNotAvailable:
            return "Biometric authentication is not available on this device"
        case .userCancelled:
            return "Authentication was cancelled by user"
        case .systemError(let error):
            return "System error: \(error.localizedDescription)"
        }
    }
}
