//
//  AuthenticationViewModel.swift
//  SecureAuth
//
//  Created by Taooufiq El moutaoouakil on 3/16/25.
//

import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var statusMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false

    private let authSDK: BiometricAuthSDK
    private let authenticator: BiometricAuthenticator
    private let networkService: NetworkService

    init(authSDK: BiometricAuthSDK = BiometricAuthSDK(), authenticator: BiometricAuthenticator = BiometricAuthenticator(), networkService: NetworkService = NetworkService()) {
        self.authSDK = authSDK
        self.authenticator = authenticator
        self.networkService = networkService
    }

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return !email.isEmpty && emailPredicate.evaluate(with: email)
    }

    func submitEmail() {
        guard isValidEmail else {
            updateStatus(message: "Please enter a valid email address", isError: true)
            return
        }

        isLoading = true
        updateStatus(message: "Authenticating with biometrics...", isError: false)

        authenticator.authenticateUser { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                if let token = self.authSDK.generateToken() {
                    self.updateStatus(message: "Authentication successful. Submitting to server...", isError: false)
                    self.submitToServer(email: self.email, token: token)
                } else {
                    self.updateStatus(message: "Failed to generate token", isError: true)
                }

            case .failure(let error):
                self.isLoading = false
                self.updateStatus(message: "Authentication failed: \(error.localizedDescription)", isError: true)
            }
        }
    }

     func submitToServer(email: String, token: BiometricAuthSDK.AuthToken) {
        networkService.submitToServer(email: email, token: token) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.updateStatus(message: "Authentication successful!", isError: false)
                case .failure(let error):
                    self.updateStatus(message: "Server error: \(error.localizedDescription)", isError: true)
                }
            }
        }
    }

     func updateStatus(message: String, isError: Bool) {
        DispatchQueue.main.async {
            self.statusMessage = message
            self.isError = isError
        }
    }
}
