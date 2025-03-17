//
//  BiometricAuthenticator.swift
//  SecureAuth
//
//  Created by Taooufiq El moutaoouakil on 3/16/25.
//

import LocalAuthentication
import Foundation

class BiometricAuthenticator {
    func authenticateUser(completion: @escaping (Result<Void, BiometricError>) -> Void) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(.biometryNotAvailable))
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Verify your identity") { success, authError in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    if let error = authError as? NSError, error.code == LAError.userCancel.rawValue {
                        completion(.failure(.userCancelled))
                    } else {
                        completion(.failure(.authenticationFailed))
                    }
                }
            }
        }
    }
}

