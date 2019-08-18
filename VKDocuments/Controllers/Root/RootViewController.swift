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
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSVProgressHUD()
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
    
    
    // MARK: - UI configs
    func setupSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setForegroundColor(UIColor.blue)
        SVProgressHUD.setCornerRadius(7)
        SVProgressHUD.setMinimumSize(CGSize.init(width: 100, height: 100))
    }
    
    
    // MARK: - Routing
    func openLoginView() {
        self.present(UINavigationController.init(rootViewController: LoginViewController.initialization()), animated: false)
    }
    
    func openMainView() {        
        self.present(UINavigationController.init(rootViewController: MainViewController.initialization()), animated: false)
    }

    @objc func updateMainController() {
        self.dismiss(animated: true, completion: nil)
    }
}
