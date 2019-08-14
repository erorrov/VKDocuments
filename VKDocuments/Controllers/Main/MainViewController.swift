//
//  ViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 11/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit

final class MainViewController: BaseViewController {

    static func initialization() -> MainViewController {
        let storyboard = UIStoryboard.init(name: StoryboardIDs.main.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ControllerStoryboardIDs.main.rawValue) as! MainViewController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
