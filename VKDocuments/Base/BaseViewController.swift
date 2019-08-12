//
//  BaseViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 11/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit


class BaseViewController: UIViewController {
    private var statusBarStyle: UIStatusBarStyle?
    
    var parentNavigation: UINavigationController? {
        if self.navigationController != nil {
            return self.navigationController
        } else {
            return self.parent?.navigationController
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle ?? .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func lightStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.statusBarStyle = .lightContent
    }
    
    func darkStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.statusBarStyle = .default
    }
}


extension BaseViewController {
    func didTapView() {
        self.view.endEditing(true)
    }
}
