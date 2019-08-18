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
    @IBOutlet private weak var noDocumentsView: UIView!
    
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
        self.configureTableView()
    }

    
    // MARK: - UI methods
    func setupUI() {
        loadData()
        
        let logoutButton = UIBarButtonItem(title: "Выйти", style: .plain, target: self, action: #selector(logout))
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.navigationItem.rightBarButtonItem = logoutButton
        self.title = "Мои документы"
    }
    
    func configureTableView() {
        tableView.register(UINib.init(nibName: DocumentCell.identifier, bundle: nil), forCellReuseIdentifier: DocumentCell.identifier)
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
    }
    
    @objc func logout() {
        let alert = UIAlertController(title: "Выйти из аккаунта?", message: "Вы уверены, что хотите выйти из аккаунта?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { _ in SC.services.apiManager.forceLogout() }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Data methods
    @objc func updateData() {
        self.documentsArray.removeAll()
        self.refreshControl.endRefreshing()
        self.initialLoad = true
        loadData()
    }
    
    func loadData() {
        if isDataLoading || isEndReached { return }
        if initialLoad { isEndReached = false }
        isDataLoading = true
        
        SVProgressHUD.show()
        SC.services.apiManager.getDocuments(ownerID: UserManager.manager.userID, count: 20, offset: self.documentsArray.count, success: { [weak self] response in
            SVProgressHUD.hideOnMain()
            self?.isDataLoading = false
            
            do {
                let documents = try JSONDecoder().decode(Documents.self, from: response as! Data)
                
                self?.noDocumentsView.isHidden = documents.count == 0 ? false : true
                
                // if offset greater or equal to total files count
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
        }) { error in
            SVProgressHUD.hideOnMain()
            
            let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понятно", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        self.isEndReached = false
        self.updateData()
    }
    
    
    // MARK: - Deleting and Renaming documents
    func deleteDocument(ownerID: Int, documentID: Int, index: Int) {
        SVProgressHUD.show()
        
        SC.services.apiManager.deleteDocument(ownerID: ownerID, docID: documentID, success: { response in
            SVProgressHUD.hideOnMain()
           self.deleteCell(index: index)
        }) { error in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            print(error)
        }
    }
    
    func editDocument(ownerID: Int, documentID: Int, title: String, index: Int) {
        SVProgressHUD.show()
        
        SC.services.apiManager.editDocument(ownerID: ownerID, docID: documentID, title: title, success: { response in
            SVProgressHUD.hideOnMain()
            self.renameCell(index: index, actualName: title)
        }) { error in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            print(error)
        }
    }
    
    
    // MARK: - Deleting and Renaming cells
    func deleteCell(index: Int) {
        self.documentsArray.remove(at: index)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .left)
        self.tableView.endUpdates()
    }
    
    func renameCell(index: Int, actualName: String) {
        self.documentsArray[index].title = actualName
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .top)
    }
}

// MARK: - TableView Data Source and Delegate Methods
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentCell.identifier, for: indexPath) as! DocumentCell
        if self.documentsArray.count > 0 {
            cell.update(for: self.documentsArray[indexPath.row])
        }
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL.init(string: self.documentsArray[indexPath.row].url)!
        self.openSafari(url: url)
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DocumentCell.height
    }
}

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height && scrollView.contentSize.height > scrollView.frame.height {
            loadData()
        }
    }
}


// MARK: - Document Cell Actions
extension MainViewController: DocumentCellDelegate {
    func openDocumentOnCell(cell: DocumentCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        SVProgressHUD.show() // withStatus: "Загрузка документа"
        
        let doc = self.documentsArray[indexPath.row]
        SC.services.apiManager.downloadDocument(url: doc.url, fileExtension: doc.ext, success: { response in
            SVProgressHUD.hideOnMain()
            guard let url = response as? URL else { return }
            print(url)
            self.navigationController?.pushViewController(DocumentPreviewViewController.initialization(fileURL: url), animated: true)
        }) { error in
            SVProgressHUD.hideOnMain()
            print(error)
        }
    }
    
    
    // TODO: check newName without API request
    func renameOnCell(cell: DocumentCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        let doc = self.documentsArray[indexPath.row]
        let alert = UIAlertController(title: "Переименовать файл", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in textField.text = doc.title }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Переименовать", style: .default, handler: { [weak alert] _ in
            let newName = alert!.textFields![0].text ?? doc.title
            self.editDocument(ownerID: doc.ownerID, documentID: doc.id, title: newName, index: indexPath.row)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func deleteOnCell(cell: DocumentCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        let doc = self.documentsArray[indexPath.row]
        let alert = UIAlertController(title: "Удаление файла", message: "Это действие нельзя будет отменить. Вы уверены что хотите удалить \(doc.title)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { _ in
            self.deleteDocument(ownerID: doc.ownerID, documentID: doc.id, index: indexPath.row)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

