import UIKit

final class APIError: NSError {
    fileprivate static var domain = "com.error"
    
    init(error: NSError) {
        super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
    }
    
    init?(code: ErrorCodes) {
        if code == .success { return nil }
        super.init(domain: APIError.domain, code: code.rawValue, userInfo: [NSLocalizedDescriptionKey: code.localizedDescription()])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum ErrorCodes: Int, RawRepresentable {
        case success = 0
        
        case unknowError = 1
        case accessDenied = 15
        case invalidParameters = 100
        case invalidDocumentIitle = 1152
        case documentAccessDenied = 1153
        
        func localizedDescription() -> String {
            switch self {
            case .unknowError: return "Неизвестная ошибка"
            case .accessDenied, .documentAccessDenied: return "Нет доступа"
            case .invalidParameters: return "Неприавльный запрос"
            case .invalidDocumentIitle: return "Не указано название документа"
            default: return "Ошибка API VK"
            }
        }
    }
    
}
