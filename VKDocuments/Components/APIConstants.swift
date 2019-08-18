//
//  APIConstants.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import Foundation

public struct URLs {
    static let DefaultAvatar = "https://vk.com/images/camera_200.png"
    static let Base = "https://api.vk.com/method/"
    static let AuthScope = "https://oauth.vk.com/authorize?client_id=7084437&scope=offline,friends,docs&redirect_uri=https://oauth.vk.com/blank.html&display=mobile&v=5.53&response_type=token"
    static let AuthResult = "https://oauth.vk.com/blank.html#"
}

enum HTTPMethods : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
