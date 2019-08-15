//
//  ViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 11/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit
import SVProgressHUD

final class MainViewController: BaseViewController {

    static func initialization() -> MainViewController {
        let storyboard = UIStoryboard.init(name: StoryboardIDs.main.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ControllerStoryboardIDs.main.rawValue) as! MainViewController
        return controller
    }
    
    @IBOutlet private weak var tableView: UITableView!

    private var documentsArray = [Document]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        tableView.register(UINib.init(nibName: DocumentCell.identifier, bundle: nil), forCellReuseIdentifier: DocumentCell.identifier)
        tableView.separatorStyle = .none
    }
    

    func setupUI() {
        SVProgressHUD.show()
    
        SC.services.apiManager.getDocuments(ownerID: UserManager.manager.userID, count: 10, offset: 0, success: { [weak self] (response) in
            SVProgressHUD.hideOnMain()
            
            do {
                let documents = try JSONDecoder().decode(Documents.self, from: response as! Data)
                self?.documentsArray = documents.documentsArray
                self?.tableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            SVProgressHUD.hideOnMain()
            print(error)
        }
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentCell.identifier, for: indexPath) as! DocumentCell
        cell.update(for: self.documentsArray[indexPath.row])
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DocumentCell.height
    }
}

