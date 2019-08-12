import UIKit


final class APIError: NSError {
    
    fileprivate static var domain = "com.error"
    
    init(error: NSError) {
        super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
    init?(code: ErrorCodes, errorDescription: String) {
        if code == .success { return nil }
        super.init(domain: APIError.domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum ErrorCodes: Int, RawRepresentable {
        
        case success = 0
        
        // unknow
        case unknowError = -99
        // parse error
        case serverResultCodeParseError = -999
        
        case consultationCompleted = 400
        
        func localizedDescription() -> String {
            switch self {
            case .success:
                return ""
            default:
                return ""
            }
        }
        
    }
    
}


