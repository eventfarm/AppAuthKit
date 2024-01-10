//
//  CredentialsManagerError.swift
//  CheckInRebornDataProviders
//
//  Created by Vladyslav Ternovskyi on 07.01.2024.
//

import Foundation

/// Represents an error during a Credentials Manager operation.
public struct CredentialsManagerError: FusionAuthError {

    enum Code: Equatable {
        case noCredentials
        case noRefreshToken
        case renewFailed
        case storeFailed
        case biometricsFailed
        case revokeFailed
        case largeMinTTL(minTTL: Int, lifetime: Int)
    }

    let code: Code

    init(code: Code, cause: Error? = nil) {
        self.code = code
        self.cause = cause
    }

    /// The underlying `Error` value, if any. Defaults to `nil`.
    public let cause: Error?

    /// Description of the error.
    ///
    /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
    public var debugDescription: String {
        self.appendCause(to: self.message)
    }
    
    func appendCause(to errorMessage: String) -> String {
        guard let cause = self.cause else {
            return errorMessage
        }

        let separator = errorMessage.hasSuffix(".") ? "" : "."
        return "\(errorMessage)\(separator) CAUSE: \(String(describing: cause))"
    }

    // MARK: - Error Cases
    /// No credentials were found in the store.
    public static let noCredentials: CredentialsManagerError = .init(code: .noCredentials)

    /// The stored ``Credentials`` instance does not contain a refresh token.
    public static let noRefreshToken: CredentialsManagerError = .init(code: .noRefreshToken)

    /// The credentials renewal failed.
    public static let renewFailed: CredentialsManagerError = .init(code: .renewFailed)

    /// Storing the renewed credentials failed.
    public static let storeFailed: CredentialsManagerError = .init(code: .storeFailed)

    /// The biometric authentication failed.
    public static let biometricsFailed: CredentialsManagerError = .init(code: .biometricsFailed)

    /// The revocation of the refresh token failed.
    public static let revokeFailed: CredentialsManagerError = .init(code: .revokeFailed)

    /// The `minTTL` requested is greater than the lifetime of the renewed access token. Request a lower `minTTL` or
    public static let largeMinTTL: CredentialsManagerError = .init(code: .largeMinTTL(minTTL: 0, lifetime: 0))

}

// MARK: - Error Messages

extension CredentialsManagerError {

    var message: String {
        switch self.code {
        case .noCredentials: return "No credentials were found in the store."
        case .noRefreshToken: return "The stored credentials instance does not contain a refresh token."
        case .renewFailed: return "The credentials renewal failed."
        case .storeFailed: return "Storing the renewed credentials failed."
        case .biometricsFailed: return "The biometric authentication failed."
        case .revokeFailed: return "The revocation of the refresh token failed."
        case .largeMinTTL(let minTTL, let lifetime): return "The minTTL requested (\(minTTL)s) is greater than the"
            + " lifetime of the renewed access token (\(lifetime)s). Request a lower minTTL or increase the"
            + " 'Token Expiration' value in the settings page of your FusionAuth API."
        }
    }

}

// MARK: - Equatable

extension CredentialsManagerError: Equatable {

    /// Conformance to `Equatable`.
    public static func == (lhs: CredentialsManagerError, rhs: CredentialsManagerError) -> Bool {
        return lhs.code == rhs.code && lhs.localizedDescription == rhs.localizedDescription
    }

}

// MARK: - Pattern Matching Operator

public extension CredentialsManagerError {

    /// Matches `CredentialsManagerError` values in a switch statement.
    static func ~= (lhs: CredentialsManagerError, rhs: CredentialsManagerError) -> Bool {
        return lhs.code == rhs.code
    }

    /// Matches `Error` values in a switch statement.
    static func ~= (lhs: CredentialsManagerError, rhs: Error) -> Bool {
        guard let rhs = rhs as? CredentialsManagerError else { return false }
        return lhs.code == rhs.code
    }
}
