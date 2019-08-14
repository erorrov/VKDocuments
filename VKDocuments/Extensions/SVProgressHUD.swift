//
//  SVProgressHUD.swift
//  VKDocuments
//
//  Created by Егор Егоров on 14/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import Foundation
import SVProgressHUD

extension SVProgressHUD {
    static func hideOnMain() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}
