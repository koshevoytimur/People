//
//  People.swift
//  People
//
//  Created by Тимур Кошевой on 25.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import Foundation

struct Humans: Codable {
    var humanDataArray: [HumanData]
    
    enum CodingKeys: String, CodingKey {
        case humanDataArray = "data"
    }
}

struct HumanData: Codable {
    let id: Int?
    let email: String?
    let first_name: String?
    let last_name: String?
    var avatar: String?
    var avatarData: Data?
}
