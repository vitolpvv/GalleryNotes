//
//  GitHubApi.swift
//  Notes
//
//  Created by VitalyP on 06/08/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import Foundation

struct Token: Codable {
    let token: String
}

struct TokenRequest: Codable {
    let scopes: [String] = ["gist"]
    let note: String
}

struct Gist: Codable {
    let id: String?
    let description: String?
    let files: [String: GistFile]
}

struct GistFile: Codable {
    let content: String?
}
