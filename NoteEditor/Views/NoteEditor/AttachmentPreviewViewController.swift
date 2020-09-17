//
//  AttachmentPreviewViewController.swift
//  Note Editor
//
//  Created by Thang Pham on 9/10/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class AttachmentPreviewViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var fileTitle: UILabel!
    
    var fileUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(URLRequest(url: self.fileUrl))
    }
    
    @IBAction func tapDoneBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapExportBtn(_ sender: Any) {
        
    }
    
}
