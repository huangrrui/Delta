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
    var isImportComplete: Bool {
        UserDefaults.standard.bool(forKey: Constant.isImportCompleteKey)
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
                self.progressLable.isHidden = false
                self.progressLable.text = "\(progressText) %"
            }
        }
    }
    
    /// 解压游戏到 Document 目录中
    func unzipGames(_ completion: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            guard let sourcePath = Bundle.main.path(forResource: "NES", ofType: "zip") else {
                return
            }
            guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let sourceURL = URL(fileURLWithPath: sourcePath)
            do {
                try FileManager.default.unzipItem(at: sourceURL, to: documentURL, progress: self.unzipProgress)
                ImportController.iTunesAutoImport { error in
                    UserDefaults.standard.setValue(true, forKey: Constant.isImportCompleteKey)
                    completion(error)
                }
            } catch {
                if let contents = try? FileManager.default.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil) {
                    for url in contents {
                        guard url.lastPathComponent.contains(".nes")
                                || url.lastPathComponent == "__MACOSX" else {
                            continue
                        }
                        try? FileManager.default.removeItem(at: url)
                    }
                } else {
                }
                completion(UnzipError.error)
            }
        }
    }
}

extension StarterViewController {
    enum Constant {
        static let isImportCompleteKey = "isUnzipCompleteKey"
    }
}
enum UnzipError: Error {
    case error
}

extension UnzipError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error:
            "Initial Failed, please click retry"
        }
    }
}
