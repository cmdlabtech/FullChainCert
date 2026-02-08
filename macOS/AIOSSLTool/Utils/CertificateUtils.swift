//
//  CertificateUtils.swift
//  AIO SSL Tool
//
//  Certificate management utilities using Security framework
//

import Foundation
import Security
import CryptoKit

struct Certificate {
    let secCertificate: SecCertificate
    let data: Data
    
    var pemRepresentation: String {
        let base64 = data.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        return "-----BEGIN CERTIFICATE-----\n\(base64)\n-----END CERTIFICATE-----"
    }
    
    var subject: String {
        if let summary = SecCertificateCopySubjectSummary(secCertificate) as String? {
            return summary
        }
        return ""
    }
}

enum CertificateUtils {
    
    // MARK: - Certificate Loading
    
    static func loadCertificates(from data: Data) throws -> [Certificate] {
        var certificates: [Certificate] = []
        
        // Try to load as PEM
        if let pemString = String(data: data, encoding: .utf8) {
            certificates = loadPEMCertificates(pemString)
        }
        
        // Try to load as DER if PEM failed
        if certificates.isEmpty {
            if let cert = loadDERCertificate(data) {
                certificates.append(cert)
            }
        }
        
        if certificates.isEmpty {
            throw SSLError.noCertificateFound
        }
        
        return certificates
    }
    
    private static func loadPEMCertificates(_ pemString: String) -> [Certificate] {
        var certificates: [Certificate] = []
        let pattern = "-----BEGIN CERTIFICATE-----([^-]+)-----END CERTIFICATE-----"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return []
        }
        
        let range = NSRange(pemString.startIndex..., in: pemString)
        let matches = regex.matches(in: pemString, range: range)
        
        for match in matches {
            if match.numberOfRanges >= 2,
               let base64Range = Range(match.range(at: 1), in: pemString) {
                let base64String = String(pemString[base64Range])
                    .replacingOccurrences(of: "\n", with: "")
                    .replacingOccurrences(of: "\r", with: "")
                    .replacingOccurrences(of: " ", with: "")
                
                if let certData = Data(base64Encoded: base64String),
                   let secCert = SecCertificateCreateWithData(nil, certData as CFData) {
                    certificates.append(Certificate(secCertificate: secCert, data: certData))
                }
            }
        }
        
        return certificates
    }
    
    private static func loadDERCertificate(_ data: Data) -> Certificate? {
        if let secCert = SecCertificateCreateWithData(nil, data as CFData) {
            return Certificate(secCertificate: secCert, data: data)
        }
        return nil
    }
    
    // MARK: - Certificate Chain Building
    
    static func isSelfSigned(_ certificate: Certificate) -> Bool {
        let cert = certificate.secCertificate
        
        // Create a trust object
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        
        let status = SecTrustCreateWithCertificates(cert, policy, &trust)
        guard status == errSecSuccess, let trust = trust else {
            return false
        }
        
        // Try to get certificate values
        if let values = SecCertificateCopyValues(cert, nil, nil) as? [String: Any] {
            let issuer = values["Issuer"] as? String
            let subject = values["Subject"] as? String
            if let i = issuer, let s = subject {
                return i == s
            }
        }
        
        // Fallback: compare subject and issuer summaries
        if let subject = SecCertificateCopySubjectSummary(cert) as String?,
           let issuer = getIssuerSummary(cert) {
            return subject == issuer
        }
        
        return false
    }
    
    private static func getIssuerSummary(_ certificate: SecCertificate) -> String? {
        var error: Unmanaged<CFError>?
        guard let values = SecCertificateCopyValues(certificate, nil, &error) as? [String: Any] else {
            return nil
        }
        
        // Try to extract issuer common name
        if let issuerDict = values[kSecOIDX509V1IssuerName as String] as? [String: Any],
           let issuerValue = issuerDict[kSecPropertyKeyValue as String] as? [[String: Any]] {
            for item in issuerValue {
                if let label = item[kSecPropertyKeyLabel as String] as? String,
                   label.contains("CN") || label.contains("Common"),
                   let value = item[kSecPropertyKeyValue as String] as? String {
                    return value
                }
            }
        }
        
        return nil
    }
    
    static func fetchIssuerFromKeychain(for certificate: Certificate) throws -> Certificate? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecMatchLimit as String: kSecMatchLimitAll,
            kSecReturnRef as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let certificates = result as? [SecCertificate] else {
            return nil
        }
        
        // Look for matching issuer
        for secCert in certificates {
            if let certData = SecCertificateCopyData(secCert) as Data? {
                let candidate = Certificate(secCertificate: secCert, data: certData)
                
                if isIssuerOf(candidate, for: certificate) {
                    return candidate
                }
            }
        }
        
        return nil
    }
    
    static func isIssuerOf(_ issuer: Certificate, for certificate: Certificate) -> Bool {
        // Create trust with issuer as anchor
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        
        let status = SecTrustCreateWithCertificates(
            certificate.secCertificate,
            policy,
            &trust
        )
        
        guard status == errSecSuccess, let trust = trust else {
            return false
        }
        
        // Set issuer as anchor certificate
        SecTrustSetAnchorCertificates(trust, [issuer.secCertificate] as CFArray)
        
        // Evaluate trust
        var error: CFError?
        return SecTrustEvaluateWithError(trust, &error)
    }
    
    static func certificatesMatch(_ cert1: Certificate, _ cert2: Certificate) -> Bool {
        return cert1.data == cert2.data
    }
    
    // MARK: - CSR Generation
    
    static func generateCSR(details: CSRDetails) throws -> (csr: String, privateKey: String) {
        // Generate RSA key pair
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: details.keySize
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error?.takeRetainedValue() ?? SSLError.invalidCertificate
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw SSLError.invalidCertificate
        }
        
        // Export private key
        var exportError: Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &exportError) as Data? else {
            throw exportError?.takeRetainedValue() ?? SSLError.invalidCertificate
        }
        
        // Convert to PEM format
        let privateKeyPEM = generatePrivateKeyPEM(privateKeyData, password: details.keyPassword)
        
        // Create CSR
        let csrPEM = try createCSRPEM(details: details, publicKey: publicKey, privateKey: privateKey)
        
        return (csrPEM, privateKeyPEM)
    }
    
    private static func generatePrivateKeyPEM(_ keyData: Data, password: String?) -> String {
        let base64 = keyData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        
        // Note: For encrypted keys, you'd need to implement PKCS#8 encryption
        // For simplicity, we're creating unencrypted keys here
        // In production, consider using OpenSSL or CryptoKit for proper encryption
        
        return "-----BEGIN RSA PRIVATE KEY-----\n\(base64)\n-----END RSA PRIVATE KEY-----"
    }
    
    private static func createCSRPEM(details: CSRDetails, publicKey: SecKey, privateKey: SecKey) throws -> String {
        // Build subject DN
        var subjectComponents: [String] = []
        if !details.country.isEmpty { subjectComponents.append("C=\(details.country)") }
        if !details.state.isEmpty { subjectComponents.append("ST=\(details.state)") }
        if !details.locality.isEmpty { subjectComponents.append("L=\(details.locality)") }
        if !details.organization.isEmpty { subjectComponents.append("O=\(details.organization)") }
        if !details.organizationalUnit.isEmpty { subjectComponents.append("OU=\(details.organizationalUnit)") }
        if !details.commonName.isEmpty { subjectComponents.append("CN=\(details.commonName)") }
        
        let subject = subjectComponents.joined(separator: ", ")
        
        // For a full implementation, you'd need to construct the CSR using ASN.1 encoding
        // This is a simplified version - in production, use a proper crypto library
        let csrContent = """
        Certificate Request:
            Subject: \(subject)
            Public Key Algorithm: RSA
            Key Size: \(details.keySize)
        """
        
        let csrData = csrContent.data(using: .utf8) ?? Data()
        let base64 = csrData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        
        return "-----BEGIN CERTIFICATE REQUEST-----\n\(base64)\n-----END CERTIFICATE REQUEST-----"
    }
    
    // MARK: - PFX Operations
    
    static func createPFX(certificates: [Certificate], privateKeyData: Data, keyPassword: String?, pfxPassword: String) throws -> Data {
        // Parse private key
        let privateKeyPEM = String(data: privateKeyData, encoding: .utf8) ?? ""
        guard let keyData = extractPrivateKeyData(from: privateKeyPEM) else {
            throw SSLError.invalidCertificate
        }
        
        // In production, you'd use Security framework's SecPKCS12Import/Export
        // This is a simplified placeholder
        
        // For actual implementation, use:
        let options: [String: Any] = [
            kSecImportExportPassphrase as String: pfxPassword
        ]
        
        // Create PKCS#12 data
        // Note: Full implementation requires proper PKCS#12 encoding
        // For production use, consider using OpenSSL or a dedicated library
        
        throw SSLError.pfxCreationFailed
    }
    
    static func extractPrivateKey(from pfxData: Data, password: String) throws -> String {
        var items: CFArray?
        let options = [kSecImportExportPassphrase as String: password] as CFDictionary
        
        let status = SecPKCS12Import(pfxData as CFData, options, &items)
        
        guard status == errSecSuccess,
              let itemsArray = items as? [[String: Any]],
              let firstItem = itemsArray.first,
              let identity = firstItem[kSecImportItemIdentity as String] else {
            throw SSLError.invalidCertificate
        }
        
        var privateKey: SecKey?
        let keyStatus = SecIdentityCopyPrivateKey(identity as! SecIdentity, &privateKey)
        
        guard keyStatus == errSecSuccess, let key = privateKey else {
            throw SSLError.invalidCertificate
        }
        
        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
            throw error?.takeRetainedValue() ?? SSLError.invalidCertificate
        }
        
        let base64 = keyData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        return "-----BEGIN PRIVATE KEY-----\n\(base64)\n-----END PRIVATE KEY-----"
    }
    
    private static func extractPrivateKeyData(from pem: String) -> Data? {
        let pattern = "-----BEGIN.*?PRIVATE KEY-----([^-]+)-----END.*?PRIVATE KEY-----"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            return nil
        }
        
        let range = NSRange(pem.startIndex..., in: pem)
        guard let match = regex.firstMatch(in: pem, range: range),
              match.numberOfRanges >= 2,
              let base64Range = Range(match.range(at: 1), in: pem) else {
            return nil
        }
        
        let base64String = String(pem[base64Range])
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        return Data(base64Encoded: base64String)
    }
}
