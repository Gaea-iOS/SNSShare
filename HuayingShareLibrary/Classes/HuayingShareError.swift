//
//  HuayingShareError.swift
//  Pods
//
//  Created by lzc1104 on 2017/10/17.
//
//

import Foundation
import MonkeyKing

extension HuayingShareManager {
    
    public enum Error: Swift.Error {
        case noAccount
        case messageCanNotBeDelivered
        case invalidImageData
        
        public enum SDKReason {
            case unknown
            case invalidURLScheme
            case urlEncodeFailed
            case serializeFailed
            case cancel
            
        }
        case sdk(reason: SDKReason)
        
        public struct APIRequestReason {
            public enum ReasonType {
                case unrecognizedError
                case connectFailed
                case invalidToken
            }
            public var type: ReasonType
            public var responseData: [String: Any]?
        }
        case apiRequest(reason: APIRequestReason)
        
        
        
    }
    
    func errorReason(with responseData: [String: Any], at platform: HuayingShareManager.SupportedPlatform) -> Error.APIRequestReason {
        
        let unrecognizedReason = HuayingShareManager.Error.APIRequestReason(type: .unrecognizedError, responseData: responseData)
        switch platform {
        case .weibo:
            
            // ref: http://open.weibo.com/wiki/Error_code
            guard let errorCode = responseData["error_code"] as? Int else {
                return unrecognizedReason
            }
            switch errorCode {
            case 21314, 21315, 21316, 21317, 21327, 21332:
                return Error.APIRequestReason(type: .invalidToken, responseData: responseData)
            default:
                return unrecognizedReason
            }
            
        default:
            return unrecognizedReason
        }
    }
    
    
    
}


extension HuayingShareManager.Error: LocalizedError {
    
    public var errorDescription: String {
        switch self {
        case .invalidImageData:
            return "Convert image to data failed."
        case .noAccount:
            return "There no invalid developer account."
        case .messageCanNotBeDelivered:
            return "Message can't be delivered."
        case .apiRequest(reason: let reason):
            
            switch reason.type {
            case .invalidToken:
                return "The token is invalid or expired."
            case .connectFailed:
                return "Can't open the API link."
            default:
                return "API invoke failed."
            }
        case .sdk(let reason):
            switch reason {
            case .cancel:
                return "Cancel by Source sdk"
            default:
                return "Unsupport Error"
            }
        }
    }
}
