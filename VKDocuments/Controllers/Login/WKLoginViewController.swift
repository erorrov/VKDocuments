//
//  WKLoginViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 13/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

final class WKLoginViewController: BaseViewController {

    static func initialization() -> WKLoginViewController {
        let storyboard = UIStoryboard.init(name: StoryboardIDs.login.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ControllerStoryboardIDs.signIn.rawValue) as! WKLoginViewController
        return controller
    }
    
    @IBOutlet private weak var webViewContainer: UIView!
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupUI() {  
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.navigationDelegate = self
        self.webView.allowsBackForwardNavigationGestures = true
        self.webViewContainer.addSubview(self.webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        ])
        
        self.title = "Авторизация"
        
        self.openAuthPage()
    }
    
    func openAuthPage() {
        self.webView.load(URLRequest(url: URL(string: URLs.AuthScope)!))
    }
}

// TODO: hide result page
extension WKLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.hideOnMain()
        
        let errorText: String
        
        switch error._code {
        case NSURLErrorNotConnectedToInternet:
            errorText = "Проверьте соединение с интернетом"
        case NSURLErrorTimedOut:
            errorText = "Время ожидания загрузки страницы истекло"
        default:
            errorText = "Не получилось загрузить страницу авторизации"
        }
        
        let alert = UIAlertController(title: "Ошибка", message: errorText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default, handler: { _ in
            self.openAuthPage()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.hideOnMain()
        
        guard let url = webView.url?.absoluteString, url.hasPrefix(URLs.AuthResult) else {
            return
        }
        
        var params = [String:String]()
        let query = url.dropFirst(URLs.AuthResult.count).components(separatedBy: "&")
        
        for param in query {
            let pair = param.components(separatedBy: "=")
            if pair.count != 2 { continue }
            params[pair[0]] = pair[1]
        }
        
        if params["error"] != nil {
            let alert = UIAlertController(title: "Ошибка", message: "Для работы приложения необходимо разрешить доступ", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Попробовать снова", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            self.openAuthPage()
        }
        
        if let accessToken = params["access_token"], let userID = params["user_id"] {
            SC.services.apiManager.token = accessToken
            UserManager.manager.userID = userID
            
            NotificationCenter.default.post(name: NSNotification.Name.updateRootController, object: nil)
        }
    }
}
