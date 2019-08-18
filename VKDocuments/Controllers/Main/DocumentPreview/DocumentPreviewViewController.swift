//
//  DocumentPreviewViewController.swift
//  VKDocuments
//
//  Created by Егор Егоров on 17/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit
import WebKit

final class DocumentPreviewViewController: BaseViewController {
    static func initialization(fileURL: URL) -> DocumentPreviewViewController {
        let storyboard = UIStoryboard(name: StoryboardIDs.main.rawValue, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: ControllerStoryboardIDs.documentPreview.rawValue) as! DocumentPreviewViewController
        controller.fileURL = fileURL
        return controller
    }
    
    private var webView: WKWebView!
    private var fileURL: URL!
    @IBOutlet private weak var webViewContainer: UIView!
    @IBOutlet private weak var errorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    func setupUI() {
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction))
        self.navigationItem.rightBarButtonItem = shareButton
        
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.allowsBackForwardNavigationGestures = true
        self.webViewContainer.addSubview(self.webView)
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor),
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor)
        ])
        
        self.webView.loadFileURL(self.fileURL, allowingReadAccessTo: self.fileURL)
    }
    
    @objc func shareAction() {
        let activityViewController = UIActivityViewController(activityItems: [self.fileURL as Any], applicationActivities: [])
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}


// MARK: - WK Delegates
extension DocumentPreviewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.errorView.isHidden = false
    }
}
