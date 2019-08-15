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
                 method: Alamofire.HTTPMethod,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = JSONEncoding.default,
                 success: @escaping (Data)->Void,
                 failure: @escaping FailureHandler) {
        
        let headers = HTTPHeaders()
        let urlString = URLs.Base + path
        
        AF.request(urlString,
                   method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: headers).validate().responseJSON { response in
                    
                    switch response.result {
                    case .success(_):
                        guard let data = response.data else {
                            failure(APIError.init(code: .serverResultCodeParseError, errorDescription: "")!)
                            return
                        }
                        
//                        if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
//                            print(json)
//                        }

                        
                        do {
                            let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                            if error.success == false {
                                failure(APIError.init(code: .serverResultCodeParseError, errorDescription: error.message)!)
                            } else {
                                success(data)
                            }
                        } catch {
                            success(data)
                        }
                        
                        
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode, statusCode == 403 {
                            self.forceLogout()
                        } else if let data = response.data {
                            if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                                if let string = json["Message"] as? String {
                                    failure(APIError.init(code: .consultationCompleted, errorDescription: string)!)
                                    return
                                }
                            }
                        }
                        
                        failure(error)
                    }
                    
        }
    }
    
    func request(_ path: String,
                 method: HTTPMethods,
                 parameters: [String]? = nil,
                 success: @escaping (Data)->(),
                 failure: @escaping FailureHandler) {
        
        let urlString = URLs.Base + path
        var request = URLRequest.init(url: URL.init(string: urlString)!)
        request.httpMethod = method.rawValue
        
        if let _parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: _parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        
        AF.request(request).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                guard let data = response.data else {
                    failure(APIError.init(code: .serverResultCodeParseError, errorDescription: "")!)
                    return
                }
                
//                if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
//                    //print(json)
//                }
                
                do {
                    let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                    if error.success == false {
                        failure(APIError.init(code: .serverResultCodeParseError, errorDescription: error.message)!)
                    } else {
                        success(data)
                    }
                } catch {
                    success(data)
                }
                
            case .failure(let error):
                if let statusCode = response.response?.statusCode, statusCode == 403 {
                    self.forceLogout()
                } else if let data = response.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                        if let string = json["Message"] as? String {
                            failure(APIError.init(code: .serverResultCodeParseError, errorDescription: string)!)
                            return
                        }
                    }
                }
                
                failure(error)
            }
        }
    }
    
    func serialize(_ value: Any) -> Data? {
        if JSONSerialization.isValidJSONObject(value) {
            return try? JSONSerialization.data(withJSONObject: value, options: [])
        }
        else {
            return String(describing: value).data(using: .utf8)
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
        guard let token = self.token else {
            return
        }
        
        let requestURL = String.init(format: "docs.get?owner_id=%@&count=%d&offset=%d&access_token=%@&v=5.101", ownerID, count, offset, token)
        
        self.request(requestURL, method: .get, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }
    
    func deleteDocument(ownerID: String, docID: Int, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        guard let token = self.token else {
            return
        }
        
        let requestURL = String.init(format: "docs.delete?owner_id=%@&doc_id=%d&access_token=%@&v=5.101", ownerID, docID, token)
        
        self.request(requestURL, method: .get, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }
    
    func editDocument(ownerID: String, docID: Int, title: String, tags: String, success: @escaping SuccessHandler, failure: @escaping FailureHandler) {
        guard let token = self.token else {
            return
        }
        
        let requestURL = String.init(format: "docs.edit?owner_id=%@&doc_id=%d&title=%@&tags=%@&access_token=%@&v=5.101", ownerID, docID, title, tags, token)
        
        self.request(requestURL, method: .get, success: { (data) in
            success(data)
        }) { (error) in
            failure(error)
        }
    }

}
