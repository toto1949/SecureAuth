//
//  NetworkService.swift
//  SecureAuth
//
//  Created by Taooufiq El moutaoouakil on 3/16/25.
//

import Foundation

class NetworkService {
    private let serverURL = URL(string: "http://192.168.1.82:5002/api/validate-token")!

    func submitToServer(email: String, token: BiometricAuthSDK.AuthToken, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload: [String: Any] = [
            "email": email,
            "token": token.rawValue
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            completion(.failure(NSError(domain: "NetworkService", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Error preparing request"])))
            return
        }

        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let message = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    completion(.failure(NSError(domain: "NetworkService", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Server error: \(message)"])))
                    return
                }

                completion(.success(()))
            }
        }.resume()
    }
}

