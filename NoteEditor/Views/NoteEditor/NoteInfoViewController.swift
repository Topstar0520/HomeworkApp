//
//  NoteInfoViewController.swift
//  Note Editor
//
//  Created by Marko Rankovic on 7/3/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class NoteInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - Properties
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var paragraphCountLabel: UILabel!
    @IBOutlet weak var lastModifiedDateLabel: UILabel!
    @IBOutlet weak var dateOfCreationLabel: UILabel!
    var fileTypes: [FileTypeDescription]!
    var noteFile: NoteFile!
    var selectedIndex = Int(0)
    
    override func viewDidLoad() {
        fileTypes = [TXTFileDescription(), RTFFileDescription()] as [FileTypeDescription]
        wordCountLabel.text = "\(noteFile.countWords())"
        characterCountLabel.text = "\(noteFile.countCharacters())"
        paragraphCountLabel.text = "\(noteFile.countParagraphs())"
        
        if let modifiedDate = noteFile.getModifiedDate() as Date?, let createdDate = noteFile.getCreatedDate() as Date?{
            lastModifiedDateLabel.text = "\(String(describing: modifiedDate.string()))"
            dateOfCreationLabel.text = "\(String(describing: createdDate.string()))"
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    //MARK: - Segue Management
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == PREVIEW_SEGUE {
            if let exportPreviewVC = segue.destination as? ExportPreviewViewController {
                exportPreviewVC.fileType = fileTypes[selectedIndex].type
                exportPreviewVC.noteFile = noteFile
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return fileTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteInfoTableViewCellID")
        
        cell?.textLabel?.text = fileTypes[indexPath.row].name
        cell?.detailTextLabel?.text = fileTypes[indexPath.row].description
        cell?.imageView?.image = UIImage(named: fileTypes[indexPath.row].type.rawValue, in: bundle, compatibleWith: nil)
        
        //Change image size
        let itemSize = CGSize(width: 60, height: 60)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
        cell?.imageView?.image?.draw(in: imageRect)
        cell?.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return cell!
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let exportPreviewVC = storyboard.instantiateViewController(withIdentifier: "ExportPreviewViewControllerID") as! ExportPreviewViewController
        exportPreviewVC.fileType = fileTypes[selectedIndex].type
        exportPreviewVC.noteFile = noteFile
        navigationController?.pushViewController(exportPreviewVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Export To..."
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
}
