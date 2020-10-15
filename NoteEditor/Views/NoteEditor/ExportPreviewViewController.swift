//
//  ExportPreviewViewController.swift
//  Note Editor
//
//  Created by Marko Rankovic on 7/6/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class ExportPreviewViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    var fileType: ExportFileType!
    var noteFile: NoteFile!
    var exportFileURL: URL?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = false
        DispatchQueue.main.async {
            if let url = NoteExporter.sharedInstance.export(attrs: self.noteFile.attrs, to: self.fileType) {
                self.exportFileURL = url
                self.webView.loadRequest(URLRequest(url: url))
            }
        }
    }
    
    @IBAction func exportFile(_ sender: Any) {
        if let url = exportFileURL {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
    }
}
