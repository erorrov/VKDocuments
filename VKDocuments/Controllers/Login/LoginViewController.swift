//
//  LoginViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit

final class LoginViewController: BaseViewController {
    
    static func initialization() -> LoginViewController {
        let storyboard = UIStoryboard.init(name: StoryboardIDs.login.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ControllerStoryboardIDs.login.rawValue) as! LoginViewController
        return controller
    }

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var authButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
        
        self.authButton.layer.masksToBounds = true
        self.authButton.layer.cornerRadius = 5
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        self.navigationController?.pushViewController(WKLoginViewController.initialization(), animated: true)
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        let url = URL(string: "https://m.vk.com/join")!
        UIApplication.shared.open(url)
    }
}
