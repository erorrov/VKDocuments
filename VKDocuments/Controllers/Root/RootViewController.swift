//
//  RootViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
