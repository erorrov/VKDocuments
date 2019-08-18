//
//  APIManager.swift
//  VKDocuments
//
//  Created by Егор Егоров on 12/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit
import Alamofire

final class APIManager {
    typealias SuccessHandler = (Any) -> Void
    typealias FailureHandler = (Error) -> Void
    typealias ProgressHandler = (CGFloat) -> Void
    
    internal var token: String? {
        get {
            return UserDefaults.standard.object(forKey: "access_token") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "access_token")
            UserDefaults.standard.synchronize()
        }
    }
    
    func forceLogout() {
        self.token = nil
        UserManager.manager.userLogout()
        NotificationCenter.default.post(name: NSNotification.Name.updateRootController, object: nil)
    }
}


// MARK: - Requests, Abstract
extension APIManager {
    func request(_ path: String,
                 method: HTTPMethods,
                 parameters: [String]? = nil,
                 success: @escaping (Data) -> Void,
                 failure: @escaping FailureHandler) {
        
        let urlString = URLs.Base + path
        let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        var request = URLRequest(url: URL(string: encodedURL ?? "")!)
        request.httpMethod = method.rawValue
        
        if let _parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: _parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        
        Alamofire.request(request).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                guard let data = response.data else {
                    failure(APIError(code: APIError.ErrorCodes(rawValue: 1)!)!)
                    return
                }
                
               if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary{
                    print(json)
                    if let errorObject = json["error"] as? NSDictionary, let errorCode = errorObject["error_code"] as? Int {
                        failure(APIError(code: APIError.ErrorCodes(rawValue: errorCode) ?? .unknowError)!)
                        return
                    }
                }
                
                do {
                    let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                    failure(APIError(code: APIError.ErrorCodes(rawValue: error.errorCode) ?? .unknowError)!)
                } catch {
                    success(data)
                }
                
            case .failure(let error):
                failure(error)
            }
        }
    }
}

internal extension APIManager {
    enum HTTPHeaderError : Error {
        case unsupportedHTTPMethod(method : Alamofire.HTTPMethod)
    }
    
    func getHeaders(for path: String, body: Parameters?, method : Alamofire.HTTPMethod, token : String?) throws -> HTTPHeaders {
        let headers = HTTPHeaders()
        return headers
    }
    
    func handleStatusCode(_ code : Int?) -> Bool {
        guard let code = code else {return false}
        guard 200 ... 299 ~= code  else {
            return false
        }
        return true
    }
}


// MARK: - API Methods
extension APIManager {
    
    func getDocuments(ownerID: String, count: Int, offset: Int, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        guard let token = self.token else { return }
        
        let requestURL = String(format: "docs.get?owner_id=%@&count=%d&offset=%d&access_token=%@&v=5.101", ownerID, count, offset, token)
        self.request(requestURL, method: .get, success: { data in
            success(data)
        }) { error in
            failure(error)
        }
    }
    
    func deleteDocument(ownerID: Int, docID: Int, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        guard let token = self.token else { return }

        let requestURL = String(format: "docs.delete?owner_id=%d&doc_id=%d&access_token=%@&v=5.101", ownerID, docID, token)
        self.request(requestURL, method: .get, success: { data in
            success(data)
        }) { error in
            failure(error)
        }
    }
    
    func editDocument(ownerID: Int, docID: Int, title: String, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        guard let token = self.token else { return }
        
        let requestURL = String(format: "docs.edit?owner_id=%d&doc_id=%d&title=%@&access_token=%@&v=5.101", ownerID, docID, title, token)
        self.request(requestURL, method: .get, success: { data in
            success(data)
        }) { error in
            failure(error)
        }
    }
}


// MARK: - Custom Methods
extension APIManager {
    func downloadDocument(url: String, fileExtension: String, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        guard let url = URL(string: url) else { return }
        
        print(url)
        
        let request = URLRequest(url: url)
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("document.\(fileExtension)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(request, to: destination).responseData { response in
            if let destinationUrl = response.destinationURL {
                print("destinationUrl \(destinationUrl.absoluteURL)")
                if let error = response.error {
                    failure(error)
                } else {
                    success(destinationUrl.absoluteURL)
                }
            }
        }
    }
}
