//
//  AuthenticationManager.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/23.
//

import Foundation
import LocalAuthentication

final class AuthenticationManager {
    static let shared = AuthenticationManager()

    private let context: LAContext = LAContext()
    private let policy: LAPolicy = .deviceOwnerAuthentication
    private let reason = "This app uses Touch ID / Face ID to secure your data."

    func authenticate() async throws -> (success: Bool, error: any Error?) {
        try await withCheckedThrowingContinuation { continuation in
            var authError: NSError?

            guard context.canEvaluatePolicy(policy, error: &authError) else {
                continuation.resume(returning: (false, authError))
                return
            }

            context.evaluatePolicy(policy, localizedReason: reason) { success, error in
                if success {
                    continuation.resume(returning: (true, nil))
                }
                else if let laError = error as? LAError {
                    continuation.resume(returning: (false, laError))
                }
                else {
                    continuation.resume(returning: (false, error))
                }
            }
        }
    }
}
