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
    
    private var isDataLoading = false
    private var isEndReached = false
    private var initialLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        tableView.register(UINib.init(nibName: DocumentCell.identifier, bundle: nil), forCellReuseIdentifier: DocumentCell.identifier)
        tableView.separatorStyle = .none
    }
    

    func setupUI() {
        loadData()
        self.title = "Мои документы"
    }
    
    func loadData() {
        if isDataLoading || isEndReached {
            return
        }
        
        if initialLoad == true {
            isEndReached = false
        }
        
        isDataLoading = true
        
        SVProgressHUD.show()
        
        SC.services.apiManager.getDocuments(ownerID: UserManager.manager.userID, count: 20, offset: self.documentsArray.count, success: { [weak self] (response) in
            SVProgressHUD.hideOnMain()
            self?.isDataLoading = false
            
            do {
                let documents = try JSONDecoder().decode(Documents.self, from: response as! Data)
                
                if self?.documentsArray.count ?? 0 >= documents.count {
                    self?.isEndReached = true
                } else {
                    if self?.initialLoad ?? false {
                        self?.documentsArray = documents.documentsArray
                        self?.initialLoad = false
                    } else {
                        self?.documentsArray.append(contentsOf: documents.documentsArray)
                    }
                    self?.tableView.reloadData()
                }
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
