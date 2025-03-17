//
//  AuthenticationViewModelTests.swift
//  SecureAuthTests
//
//  Created on 3/16/25.
//

import XCTest
import Combine
@testable import SecureAuth

class MockBiometricAuthSDK: BiometricAuthSDK {
    var shouldSucceed = true
    var error: BiometricError = .userCancelled
    
     func authenticateUser(completion: @escaping (Result<AuthToken, BiometricError>) -> Void) {
        if shouldSucceed {
            guard let token = generateToken() else {
                completion(.failure(.systemError(NSError(domain: "BiometricSDKDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to generate token"]))))
                return
            }
            completion(.success(token))
        } else {
            completion(.failure(error))
        }
    }
    
    internal override func generateToken() -> AuthToken? {
        return AuthToken(
            userId: "test_user_id",
            deviceId: "test_device_id",
            issuedAt: Date(),
            expiresAt: Date().addingTimeInterval(600),
            rawValue: "{\"userId\":\"test_user_id\",\"deviceId\":\"test_device_id\",\"issuedAt\":1621234567,\"expiryDate\":1621235167}"
        )
    }
}

class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

class AuthenticationViewModelTests: XCTestCase {
    var viewModel: AuthenticationViewModel!
    var mockSDK: MockBiometricAuthSDK!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSDK = MockBiometricAuthSDK()
        viewModel = AuthenticationViewModel(authSDK: mockSDK)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockSDK = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testValidAndInvalidEmail() {
        let validEmails = ["test@gmail.com", "user@mail.com"]
        let invalidEmails = ["", "test", "test@", "test@gmail"]
        
        for email in validEmails {
            viewModel.email = email
            XCTAssertTrue(viewModel.isValidEmail, "\(email) should be valid")
        }
        
        for email in invalidEmails {
            viewModel.email = email
            XCTAssertFalse(viewModel.isValidEmail, "\(email) should be invalid")
        }
    }
    
    func testSubmitEmailWithInvalidEmail() {
        viewModel.email = "invalid-email"
        
        let expectation = self.expectation(description: "Status message updated")
        viewModel.$statusMessage
            .dropFirst()
            .sink { message in
                if !message.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.submitEmail()
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.statusMessage, "Please enter a valid email address")
        XCTAssertTrue(viewModel.isError)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testSubmitEmailWithBiometricSuccess() {
        mockSDK.shouldSucceed = true
        viewModel.email = "test@gmail.com"
                
        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        viewModel.$statusMessage
            .sink { message in
                if message == "Authentication successful!" {
                    print(message)
                }
            }
            .store(in: &cancellables)
        
        viewModel.submitEmail()
        
        
        XCTAssertFalse(viewModel.isError)
        XCTAssertFalse(!viewModel.isLoading)
    }
    
    func testSubmitEmailWithBiometricFailure() {
        mockSDK.shouldSucceed = false
        mockSDK.error = .authenticationFailed
        viewModel.email = "test@gmail.com"
        
        
        viewModel.$statusMessage
            .sink { message in
                if message.contains("Authentication failed") {
                    print(message)
                }
            }
            .store(in: &cancellables)
        
        viewModel.submitEmail()
        
        XCTAssertTrue(!viewModel.isError)
        XCTAssertFalse(!viewModel.isLoading)
    }
}
