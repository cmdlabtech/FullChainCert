//
//  CSRDetails.swift
//  AIO SSL Tool
//

import Foundation

struct CSRDetails {
    var commonName: String = ""
    var country: String = ""
    var state: String = ""
    var locality: String = ""
    var organization: String = ""
    var organizationalUnit: String = ""
    var email: String = ""
    var sans: [String] = []
    var keySize: Int = 2048
    var keyPassword: String? = nil
}
