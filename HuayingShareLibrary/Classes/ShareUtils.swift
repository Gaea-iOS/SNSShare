//
//  ShareUtils.swift
//  Pods
//
//  Created by lzc1104 on 2017/10/17.
//
//

import Foundation


extension Set where Element == HuayingShareManager.Account  {
    
    subscript(platform: HuayingShareManager.SupportedPlatform) -> HuayingShareManager.Account? {
        let accountSet = self
        switch platform {
        case .weChat:
            for account in accountSet {
                if case .weChat = account {
                    return account
                }
            }
        case .qq:
            for account in accountSet {
                if case .qq = account {
                    return account
                }
            }
        case .weibo:
            for account in accountSet {
                if case .weibo = account {
                    return account
                }
            }
        }
        return nil
    }
    
    subscript(platform: HuayingShareManager.Message) -> HuayingShareManager.Account? {
        let accountSet = self
        switch platform {
        case .weChat:
            for account in accountSet {
                if case .weChat = account {
                    return account
                }
            }
        case .qq:
            for account in accountSet {
                if case .qq = account {
                    return account
                }
            }
        case .weibo:
            for account in accountSet {
                if case .weibo = account {
                    return account
                }
            }
        }
        return nil
    }
}

extension URL {
    
    var monkeyking_queryDictionary: [String: Any] {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        guard let items = components?.queryItems else {
            return [:]
        }
        var infos = [String: Any]()
        items.forEach {
            if let value = $0.value {
                infos[$0.name] = value
            }
        }
        return infos
    }
}

