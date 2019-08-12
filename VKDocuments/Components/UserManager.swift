//
//  UserManager.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import Foundation


final class UserManager {
    
    static let manager = UserManager()
    
    // TODO: checking token
    func isUserLogin() -> Bool {
        // ...
        return false
    }
    
    func userLogout() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "avatar_url")
        UserDefaults.standard.synchronize()
    }
    
    var userID: Int {
        get {
            return UserDefaults.standard.object(forKey: "user_id") as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user_id")
            UserDefaults.standard.synchronize()
        }
    }
    
    var userAvatarURL: String {
        get {
            return UserDefaults.standard.object(forKey: "avatar_url") as? String ?? URLs.DefaultAvatar
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "avatar_url")
            UserDefaults.standard.synchronize()
        }
    }
    
}
