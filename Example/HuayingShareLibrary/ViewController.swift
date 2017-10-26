//
//  ViewController.swift
//  HuayingShareLibrary
//
//  Created by lzc1104 on 10/16/2017.
//  Copyright (c) 2017 lzc1104. All rights reserved.
//

import UIKit
import HuayingShareLibrary

class ViewController: UITableViewController {

    
    @IBOutlet weak var switcher: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.register()
        self.switcher.addTarget(self, action: #selector(changeShare), for: UIControlEvents.valueChanged)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeShare(switcher: UISwitch){
        
        self.navigationItem.title = switcher.isOn ? "略缩图为图片URL" : "略缩图为图片"
    }
    
    func register() {
        self.navigationItem.title = "略缩图为图片"
        let wechatAccount = HuayingShareManager.Account.weChat(
            appID: "wxd5303f3621dd900d",
            appKey: "a11e59226e19691a2f3df68fdec086d3"
        )
        
        let qqAccount = HuayingShareManager.Account.qq(appID: "1105338639")
        
        let weiboAccount = HuayingShareManager.Account.weibo(
            appID: "379457724",
            appKey: "3ed1d2f34909009dda68e379e1898150",
            redirectURL: ""
        )
        
        let accounts: [HuayingShareManager.Account] = [wechatAccount,qqAccount,weiboAccount]
        accounts.forEach(self.shareManager.registerAccount(_:))
        
        
    }
    typealias Info = (title: String?, description: String?, thumbnail: HuayingShareManager.ImageType?, media: HuayingShareManager.Media?)
    
   
    func shareWechatTimeline() {
        let message = HuayingShareManager.Message.weChat(.timeline(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareWechatSession() {
        let message = HuayingShareManager.Message.weChat(.session(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareWechatFavourite() {
        let message = HuayingShareManager.Message.weChat(.favorite(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareQQFavourite() {
        let message = HuayingShareManager.Message.qq(.favorites(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareQQDataline() {
        let message = HuayingShareManager.Message.qq(.dataline(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareQQFriends() {
        let message = HuayingShareManager.Message.qq(.friends(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareQQZone() {
        let message = HuayingShareManager.Message.qq(.zone(info: rawInfo()))
        shareManager.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func shareWeibo() {
        
        let message = HuayingShareManager.Message.weibo(.default(info: rawInfo(), accessToken: ""))
        ShareFucker.shared.deliver(message, completionHandler: ViewController.resultHanler)
    }
    
    func rawInfo() -> Info {
        return self.switcher.isOn ? self.wechatURLInfo : self.wechatImageInfo
    }
    
    static func resultHanler(result: HuayingShareManager.DeliverResult) {
        switch result {
        case .success(let ok):
            let vc = UIAlertController(title: "Fuck Me", message:"分享成功", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            vc.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
            break
        case .failure(let error):
            
            let reason = error.errorDescription
            print(reason)
            let vc = UIAlertController(title: "Fuck Me", message: reason, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            vc.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    var wechatImageInfo: Info  {
        let media = HuayingShareManager.Media.url(URL(string: "www.baidu.com")!)
        return (title: "测试", description: "烧鹅饭", thumbnail: HuayingShareManager.ImageType.image(#imageLiteral(resourceName: "bg_tanchuang_logo")), media: media)
    }
    
    var wechatURLInfo: Info  {
        let imageurl = "https://pic4.zhimg.com/f4c09eb37_xl.jpg"
        let media = HuayingShareManager.Media.url(URL(string: "www.baidu.com")!)
        return (title: "测试", description: "烧鹅饭", thumbnail: HuayingShareManager.ImageType.url(imageurl), media: media)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.functions[indexPath.row]()
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    var functions: [() -> Void] {
        return [
            self.shareWechatSession,
            self.shareWechatTimeline,
            self.shareWechatFavourite,
            self.shareQQFavourite,
            self.shareQQZone,
            self.shareQQDataline,
            self.shareQQFriends,
            self.shareWeibo
        ]
    }
    
    let shareManager = ShareFucker.shared

}

class ShareFucker: HuayingShareManager {
    static let shared = ShareFucker()
}


