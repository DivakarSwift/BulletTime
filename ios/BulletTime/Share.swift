//
//  Share.swift
//  BulletTime
//
//  Created by leo on 16/8/16.
//  Copyright © 2016年 ltebean. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import SVProgressHUD

class ShareItem: NSObject, UIActivityItemSource {
    
    let data: NSData
    
    init(data: NSData) {
        self.data = data
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return data
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        return data
    }
    
    func activityViewController(activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: String?) -> String {
        return CFBridgingRetain(kUTTypeGIF) as! String
    }
}

class Share: NSObject {
    
    static func shareProduct(product: Product, inViewController vc: UIViewController) {
        SVProgressHUD.show()
        vc.view.userInteractionEnabled = false
        
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("animated.gif")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(url)
        } catch {
            
        }
        GIF.createGIF(with: product.images, frameDelay: 0.2, toURL: url)
        let uuid = product.uuid.dataUsingEncoding(NSUTF8StringEncoding)!
        let shareURL = NSURL(string: "\(Config.serverURL)/p/\(product.uuid)")!
        Alamofire.upload(
            .POST,
            "\(Config.serverURL)/api/v1/upload",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: url, name: "gif")
                multipartFormData.appendBodyPart(data: uuid, name: "uuid")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        vc.view.userInteractionEnabled = true
                        if response.result.isSuccess {
                            SVProgressHUD.dismiss()
                            Share.shareURL(shareURL, inViewController: vc)
                        } else {
                            SVProgressHUD.showErrorWithStatus("Network Error")
                        }
                    }
                case .Failure(let encodingError):
                    vc.view.userInteractionEnabled = true
                    SVProgressHUD.showErrorWithStatus("Error")
                    print(encodingError)
                }
            }
        )
        
    }

    private static func shareURL(url: NSURL, inViewController vc: UIViewController) {
        let activityVC = UIActivityViewController(activityItems:[url], applicationActivities: nil)
        vc.presentViewController(activityVC, animated: true, completion: nil)
    }
}