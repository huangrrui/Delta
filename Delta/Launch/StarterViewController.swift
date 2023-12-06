//
//  StarterViewController.swift
//  Delta
//
//  Created by 黄瑞 on 2023/12/5.
//  Copyright © 2023 Riley Testut. All rights reserved.
//

import UIKit

class StarterViewController: UIViewController {
    @IBOutlet private var progressLable: UILabel!
    private var unzipProgress = Progress()
    let isUnzipCompleteKey = "isUnzipCompleteKey"
    var isUnzipComplete: Bool {
        UserDefaults.standard.bool(forKey: isUnzipCompleteKey)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unzipProgress.addObserver(self, forKeyPath: #keyPath(Progress.totalUnitCount), options: [.new], context: nil)
        unzipProgress.addObserver(self, forKeyPath: #keyPath(Progress.completedUnitCount), options: [.new], context: nil)
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.unzipProgress.totalUnitCount != 0 {
            let complete = self.unzipProgress.completedUnitCount
            let total = self.unzipProgress.totalUnitCount
            DispatchQueue.main.async {
                let progressText = "\(complete * 100 / total)"
                self.progressLable.text = "\(progressText) %"
            }
        }
    }
    
    /// 解压游戏到 Document 目录中
    func unzipGames(_ completion: ((Error?) -> Void)? = nil) {
        DispatchQueue.global().async {
            guard let sourcePath = Bundle.main.path(forResource: "Test-50", ofType: "zip") else {
                return
            }
            guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let sourceURL = URL(fileURLWithPath: sourcePath)
            do {
                try FileManager.default.unzipItem(at: sourceURL, to: documentURL, progress: self.unzipProgress)
                UserDefaults.standard.setValue(true, forKey: self.isUnzipCompleteKey)
                completion?(nil)
            } catch {
                completion?(error)
            }
        }
    }
}
