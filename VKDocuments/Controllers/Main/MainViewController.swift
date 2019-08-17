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
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        refreshControl.tintColor = UIColor.blue
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        tableView.register(UINib.init(nibName: DocumentCell.identifier, bundle: nil), forCellReuseIdentifier: DocumentCell.identifier)
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
    }
    
    func setupUI() {
        loadData()
        
        let logoutButton = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(logout))
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationItem.rightBarButtonItem = logoutButton
        
        self.title = "Мои документы"
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Выйти из аккаунта?", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in SC.services.apiManager.forceLogout() }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func updateData() {
        self.documentsArray.removeAll()
        self.refreshControl.endRefreshing()
        self.initialLoad = true
        loadData()
    }
}

private extension MainViewController {
    
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
    
    func deleteDocument(ownerID: Int, documentID: Int) {
        SVProgressHUD.show()
        
        SC.services.apiManager.deleteDocument(ownerID: ownerID, docID: documentID, success: { (response) in
            SVProgressHUD.hideOnMain()
            self.updateData()
        }) { (error) in
            SVProgressHUD.hideOnMain()
            print(error)
        }
    }
    
    func editDocument(ownerID: Int, documentID: Int, title: String) {
        SVProgressHUD.show()
        
        SC.services.apiManager.editDocument(ownerID: ownerID, docID: documentID, title: title, success: { (response) in
            SVProgressHUD.hideOnMain()
            self.updateData()
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
        cell.delegate = self
        
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DocumentCell.height
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // print("current offset = \(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height && scrollView.contentSize.height > scrollView.frame.height {
            loadData()
        }
    }
}

extension MainViewController: DocumentCellDelegate {
    func renameOnCell(cell: DocumentCell) {
        let alert = UIAlertController(title: "Переименовать файл", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = cell.document?.title
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Переименовать", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            
            guard let indexPath = self.tableView.indexPath(for: cell) else {
                return
            }
            
            self.editDocument(ownerID: self.documentsArray[indexPath.row].ownerID, documentID: self.documentsArray[indexPath.row].id, title: textField.text ?? "")
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteOnCell(cell: DocumentCell) {
        let alert = UIAlertController(title: "Удаление файла", message: "Это действие нельзя будет отменить. Вы уверены что хотите удалить \(cell.document?.title ?? "этот файл")?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { _ in
            guard let indexPath = self.tableView.indexPath(for: cell) else {
                return
            }
            
            self.deleteDocument(ownerID: self.documentsArray[indexPath.row].ownerID, documentID: self.documentsArray[indexPath.row].id)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

