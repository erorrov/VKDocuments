//
//  ServiceContainer.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import Foundation

typealias SC = ServiceContainer

final class ServiceContainer {
    static let container = ServiceContainer()

    private (set) var apiManager = APIManager()
    private (set) var userManager = UserManager()
    
    static var services: ServiceContainer {
        return SC.container
    }
}
