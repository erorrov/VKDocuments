//
//  RootViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit
import SVProgressHUD

class RootViewController: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setForegroundColor(UIColor.blue)
        SVProgressHUD.setCornerRadius(7)
        SVProgressHUD.setMinimumSize(CGSize.init(width: 100, height: 100))
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMainController), name: NSNotification.Name.updateRootController, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if SC.container.userManager.isUserLogin() {
            self.openMainView()
        } else {
            self.openLoginView()
        }
    }
    
    // TODO: Animation
    func openLoginView() {
        self.present(UINavigationController.init(rootViewController: LoginViewController.initialization()), animated: false)
    }
    
    // TODO: Animation
    func openMainView() {        
        self.present(MainViewController.initialization(), animated: false)
        
    }

}


private extension RootViewController {
    
    @objc func updateMainController() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
