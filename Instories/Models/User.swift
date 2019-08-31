//
//  User.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/6/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class User {
    
    let id: String
    
    let username: String
    
    let avatarUrl: URL
    
    var avatarImage: UIImage?
    
    var fullName: String
    
    init(id: String, username: String, avatarUrl: URL, fullName: String) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.fullName = fullName
    }
}
