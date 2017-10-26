//
//  HuayingShareManager.swift
//  Pods
//
//  Created by lzc1104 on 2017/10/16.
//
//

import UIKit
import MonkeyKing
import SDWebImage

open class HuayingShareManager {
    
    public init() {}
    var accountSet = Set<Account>()
    
    fileprivate var deliverCompletionHandler: DeliverCompletionHandler?
    
    public enum Account: Hashable {
        case weChat(appID: String, appKey: String?)
        case qq(appID: String)
        case weibo(appID: String, appKey: String, redirectURL: String)
        
        public var isAppInstalled: Bool {
            switch self {
            case .weChat:
                return HuayingShareManager.SupportedPlatform.weChat.isAppInstalled
            case .qq:
                return HuayingShareManager.SupportedPlatform.qq.isAppInstalled
            case .weibo:
                return HuayingShareManager.SupportedPlatform.weibo.isAppInstalled

            }
        }
        
        public var appID: String {
            switch self {
            case .weChat(let appID, _):
                return appID
            case .qq(let appID):
                return appID
            case .weibo(let appID, _, _):
                return appID
            }
        }
        
        public var hashValue: Int {
            return appID.hashValue
        }
        
        public var canWebOAuth: Bool {
            switch self {
            case .qq, .weibo, .weChat:
                return true
            }
        }
        
        public static func ==(lhs: Account, rhs: Account) -> Bool {
            return lhs.appID == rhs.appID
        }
        
        func asMonkeyKingAccount() -> MonkeyKing.Account {
            switch self {
            case .weChat(let appID, let appKey):
                return MonkeyKing.Account.weChat(appID: appID, appKey: appKey)
            case .qq(let appID):
                return MonkeyKing.Account.qq(appID: appID)
            case .weibo(let appID, let appKey, let redirectURL):
                return MonkeyKing.Account.weibo(appID: appID, appKey: appKey, redirectURL: redirectURL)
            }
        }
        
        
    }
    
    public enum SupportedPlatform {
        case qq
        case weChat
        case weibo
        
        public var isAppInstalled: Bool {
            switch self {
            case .weChat:
                return HuayingShareManager.canOpenURL(urlString: "weixin://")
            case .qq:
                return HuayingShareManager.canOpenURL(urlString: "mqqapi://")
            case .weibo:
                return HuayingShareManager.canOpenURL(urlString: "weibosdk://request")
            }
        }
    }
    
    public enum Media {
        case url(URL)
        case image(UIImage)
        case audio(audioURL: URL, linkURL: URL?)
        case video(URL)
        case file(Data)
        
        func asMonkeyKingMedia() -> MonkeyKing.Media {
            switch self {
            case .url(let url):
                return .url(url)
            case .image(let image):
                return .image(image)
            case .video(let video):
                return .video(video)
            case .file(let data):
                return .file(data)
            case .audio(let audioURL, let linkURL):
                return .audio(audioURL: audioURL, linkURL: linkURL)
            }
        }
    }
    
    open func registerAccount(_ account: Account) {
        guard account.isAppInstalled || account.canWebOAuth else { return }
        for oldAccount in self.accountSet {
            switch oldAccount {
            case .weChat:
                if case .weChat = account { self.accountSet.remove(oldAccount) }
            case .qq:
                if case .qq = account { self.accountSet.remove(oldAccount) }
            case .weibo:
                if case .weibo = account { self.accountSet.remove(oldAccount) }
            }
        }
        self.accountSet.insert(account)
        MonkeyKing.registerAccount(account.asMonkeyKingAccount())
    }
    
    
    
    public enum DeliverResult {
        case success(ResponseJSON?)
        case failure(Error)
    }
    
    public typealias ResponseJSON = [String: Any]
    public typealias DeliverCompletionHandler = (_ result: DeliverResult) -> Void
    
    class func canOpenURL(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    public func deliver(_ message: Message, completionHandler: @escaping DeliverCompletionHandler) {
        
        if message.needImageDownload(),
            let url = message.thumbnilURL() {
            
            SDWebImageDownloader.shared()
                .downloadImage(
                with: url,
                options: SDWebImageDownloaderOptions.ignoreCachedResponse, progress: nil) { (image, _, _, _) in
                    if let img = image {
                        MonkeyKing.deliver(message.asImageInfo(image: img).asMonkeyMessage(), completionHandler: { (result) in
                            completionHandler(result.asShareResult())
                        })
                    } else {
                        MonkeyKing.deliver(message.asMonkeyMessage(), completionHandler: { (result) in
                            completionHandler(result.asShareResult())
                        })
                    }
                    
            }
        } else {
            MonkeyKing.deliver(message.asMonkeyMessage(), completionHandler: { (result) in
                completionHandler(result.asShareResult())
            })
        }
        
        
    }
    public enum ImageType {
        case image(UIImage)
        case url(String)
        
        var image: UIImage? {
            switch self {
            case .image(let image):
                return image
            default:
                return nil
            }
        }
        
        var imageURL: String? {
            switch self {
            case .image(_):
                return nil
            case .url(let url):
                return url
            }
        }
        
    }
    public typealias Info = (title: String?, description: String?, thumbnail: ImageType?, media: Media?)
    public enum Message {
        
        func needImageDownload() -> Bool {
            switch self {
            case .weChat(let type):
                return type.info.thumbnail?.image == nil
            case .qq(let type):
                return type.info.thumbnail?.image == nil
            case .weibo(let type):
                return type.info.thumbnail?.image == nil
            }
        }
        
        func thumbnilURL() -> URL? {
            switch self {
            case .weChat(let type):
                return URL(string: (type.info.thumbnail?.imageURL ?? ""))
            case .qq(let type):
                return URL(string: (type.info.thumbnail?.imageURL ?? ""))
            case .weibo(let type):
                return URL(string: (type.info.thumbnail?.imageURL ?? ""))
            }
        }
        
        func asImageInfo(image: UIImage) -> Message {
            switch self {
            case .weChat(let type):
                switch type {
                case .favorite(let info):
                    return Message.weChat(.favorite(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                case .session(let info):
                    return Message.weChat(.session(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                case .timeline(let info):
                    return Message.weChat(.timeline(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                    
                }
            case .qq(let type):
                switch type {
                case .dataline(let info):
                    return Message.qq(.dataline(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                case .favorites(let info):
                    return Message.qq(.favorites(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                case .friends(let info):
                    return Message.qq(.friends(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                case .zone(let info):
                    return Message.qq(.zone(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image), media: info.media)))
                    
                }
            case .weibo(let type):
                switch type {
                case .default(let info, let accessToken):
                    return Message.weibo(HuayingShareManager.Message.WeiboSubtype.default(info: (title: info.title, description: info.description, thumbnail: HuayingShareManager.ImageType.image(image) , media: info.media), accessToken: accessToken))
                }
            }
        }
        
        public enum WeChatSubtype {
            case session(info: Info)
            case timeline(info: Info)
            case favorite(info: Info)
            
            var scene: String {
                switch self {
                case .session:
                    return "0"
                case .timeline:
                    return "1"
                case .favorite:
                    return "2"
                }
            }
            
            var info: Info {
                switch self {
                case .session(let info):
                    return info
                case .timeline(let info):
                    return info
                case .favorite(let info):
                    return info
                }
            }
            
            func asMonkeyKingSubType() -> MonkeyKing.Message.WeChatSubtype {
                switch self {
                case .session(let info):
                    return MonkeyKing.Message.WeChatSubtype.session(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                case .timeline(let info):
                    return MonkeyKing.Message.WeChatSubtype.timeline(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                case .favorite(let info):
                    return MonkeyKing.Message.WeChatSubtype.favorite(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                }
            }
        }
        case weChat(WeChatSubtype)
        
        public enum QQSubtype {
            case friends(info: Info)
            case zone(info: Info)
            case favorites(info: Info)
            case dataline(info: Info)
            
            var scene: Int {
                switch self {
                case .friends:
                    return 0x00
                case .zone:
                    return 0x01
                case .favorites:
                    return 0x08
                case .dataline:
                    return 0x10
                }
            }
            
            var info: Info {
                switch self {
                case .friends(let info):
                    return info
                case .zone(let info):
                    return info
                case .favorites(let info):
                    return info
                case .dataline(let info):
                    return info
                }
            }
            
            func asMonkeyKingSubType() -> MonkeyKing.Message.QQSubtype {
                switch self {
                case .friends(let info):
                    return MonkeyKing.Message.QQSubtype.friends(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                case .zone(let info):
                    return MonkeyKing.Message.QQSubtype.friends(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                case .favorites(let info):
                    return MonkeyKing.Message.QQSubtype.favorites(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                case .dataline(let info):
                    return MonkeyKing.Message.QQSubtype.dataline(info: (title: info.title, description: info.description, thumbnail: info.thumbnail?.image, media: info.media?.asMonkeyKingMedia()))
                    
                }
            }
        }
        case qq(QQSubtype)
        
        public enum WeiboSubtype {
            case `default`(info: Info, accessToken: String?)
            
            var info: Info {
                switch self {
                case .default(let info, _):
                    return info
                }
            }
            
            var accessToken: String? {
                switch self {
                case .default(_, let accessToken):
                    return accessToken
                }
            }
            
            func asMonkeyKingSubType() -> MonkeyKing.Message.WeiboSubtype {
                switch self {
                case .default(let info):
                    return MonkeyKing.Message.WeiboSubtype.default(info: (title: info.info.title, description: info.info.description, thumbnail: info.info.thumbnail?.image, media: info.info.media?.asMonkeyKingMedia()), accessToken: info.accessToken)
                }
            }
            
        }
        case weibo(WeiboSubtype)
        
        func asMonkeyMessage() -> MonkeyKing.Message {
            switch self {
            case .qq(let type):
                
                return MonkeyKing.Message.qq(type.asMonkeyKingSubType())
                
            case .weChat(let type):
                return MonkeyKing.Message.weChat(type.asMonkeyKingSubType())
            case .weibo(let type):
                return MonkeyKing.Message.weibo(type.asMonkeyKingSubType())
            }
        }
        
    }
    
    
}

extension HuayingShareManager {
    public func handleOpenURL(_ url: URL) -> Bool {
        guard let urlScheme = url.scheme else { return false }
        // WeChat
        if urlScheme.hasPrefix("wx") {
            
            // Share
            if let _ = UIPasteboard.general.data(forPasteboardType: "content") {
                return MonkeyKing.handleOpenURL(url)
            }
        }
        // QQ Share
        if urlScheme.hasPrefix("QQ") {
            
            return MonkeyKing.handleOpenURL(url)
        }
        
        // Weibo
        if urlScheme.hasPrefix("wb") {
            let items = UIPasteboard.general.items
            var results = [String: Any]()
            for item in items {
                for (key, value) in item {
                    if let valueData = value as? Data, key == "transferObject" {
                        results[key] = NSKeyedUnarchiver.unarchiveObject(with: valueData)
                    }
                }
            }
            guard
                let responseInfo = results["transferObject"] as? [String: Any],
                let type = responseInfo["__class"] as? String else {
                    return false
            }
            guard let _ = responseInfo["statusCode"] as? Int else {
                return false
            }
            switch type {
            // Share
            case "WBSendMessageToWeiboResponse":
                
                return MonkeyKing.handleOpenURL(url)
            default:
                break
            }
        }
        
        return false
    }
}

extension MonkeyKing.Error {
    
    func asShareError() -> HuayingShareManager.Error {
        //TODO
        switch self {
        case .apiRequest(_):
            ///TODO
            let rea = HuayingShareManager.Error.APIRequestReason.init(type: HuayingShareManager.Error.APIRequestReason.Type.unrecognizedError, responseData: nil)
            return HuayingShareManager.Error.apiRequest(reason: rea)
            
        case .invalidImageData:
            return HuayingShareManager.Error.invalidImageData
        case .noAccount:
            return HuayingShareManager.Error.noAccount
        case .messageCanNotBeDelivered:
            return HuayingShareManager.Error.messageCanNotBeDelivered
        case .sdk(_):
            ///cancel
            return HuayingShareManager.Error.sdk(reason: HuayingShareManager.Error.SDKReason.cancel)
        }
    }
}

extension MonkeyKing.DeliverResult {
    func asShareResult() -> HuayingShareManager.DeliverResult {
        switch self {
        case .success(let json):
            return HuayingShareManager.DeliverResult.success(json)
        case .failure(let error):
            
            return HuayingShareManager.DeliverResult.failure(error.asShareError())
            
        }
    }
}

