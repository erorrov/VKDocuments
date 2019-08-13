//
//  RootViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit

class RootViewController: BaseViewController {
    
    @IBOutlet weak var logoImage: UIImageView!
    
    private let animationDuration = 0.4
    private let animationDelay = 0.25
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if SC.container.userManager.isUserLogin() {
            self.openMainView()
        } else {
            self.openLoginView()
        }
    }
    
    func openLoginView() {
        let vc = UIStoryboard(name: StoryboardIDs.login.rawValue, bundle: nil).instantiateViewController(withIdentifier: ControllerStoryboardIDs.login.rawValue) as! LoginViewController
        vc.loadView()
        
        UIView.animate(withDuration: animationDuration, delay: animationDelay, animations: {
            self.logoImage.center = vc.logoImage.center
        }, completion: { finished in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        })
    }
    
    func openMainView() {
        let vc = UIStoryboard(name: StoryboardIDs.main.rawValue, bundle: nil).instantiateViewController(withIdentifier: ControllerStoryboardIDs.main.rawValue) as! MainViewController
        vc.loadView()
        
        UIView.animate(withDuration: animationDuration, delay: animationDelay, animations: {
            self.logoImage.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { finished in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = vc
        })
    }

}
