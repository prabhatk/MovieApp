//
//  ImageDownloader.swift
//  mFITyics
//
//  Created by Prabhat Kasera on 25/09/16.
//  Copyright © 2016 Prabhat Kasera. All rights reserved.
//

import UIKit
class ImageDownloader : NSObject {
    var record : Record!
    var compeletionHandler : (() -> Void)!
    private var sessionTask : URLSessionTask!
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(internetRechabilityChanged), name: ReachabilityChangedNotification, object: nil)
    }
    func startDownload() {
        if (record.url != nil && (record.url?.characters.count)! > 10) {
            let urlRequest = URLRequest(url: URL(string: record.url!)!)
            sessionTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
                if error != nil {
                   // abort()
                }
                DispatchQueue.main.async {
                    if data != nil {
                    if let image = UIImage(data: data!) {
                        self.record.image = image
                    }
                    self.compeletionHandler()
                }
                }
                
            })
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.reachability.isReachable {
            self.sessionTask.resume()
        }
        else {
            self.sessionTask.suspend()
        }
        }
    }
    func cancelDownload(){
            self.sessionTask.cancel()
            self.sessionTask = nil
    }
    func internetRechabilityChanged() {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.reachability.isReachable {
            //self.sessionTask.resume()
        }
        else {
           // self.sessionTask.cancel()
        }
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


class Record : NSObject {
    var url : String?
    var image : UIImage?
    var title: String?
    var releaseDate : String?
    var overview: String?
    var movie_id : String?
    override init() {
        super.init()
    }
}
