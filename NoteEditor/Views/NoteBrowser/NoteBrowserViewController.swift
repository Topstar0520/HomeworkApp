//
//  NoteBrowserViewController.swift
//  Note Editor
//
//  Created by Marko Rankovic on 5/17/17.
//  Edited by Thang Pham on 8/15/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit

class NoteBrowserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - Properties
    
    //override var preferredStatusBarStyle: UIStatusBarStyle { return .default }
    @IBOutlet weak var tableView: UITableView!
    private var noteDescriptors = [NoteDescriptor]()
    private var selectedNote: NoteDescriptor?

    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigationBarTransparent()
        tableView.register(UINib(nibName: "NoteBrowserTableViewCell", bundle: nil), forCellReuseIdentifier: "NoteBrowserTableViewCellID")
        tableView.estimatedRowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ThemeCenter.setTheme(type: .Preview)
        AttachmentLinkBuilder.instance.noteDescriptor = nil
        DispatchQueue.main.async {
            self.noteDescriptors = EditorDB.sharedInstance.loadObjects(type: .NoteDescriptor) as! [NoteDescriptor]
            if self.noteDescriptors.isEmpty {
                self.noteDescriptors = self.populateSampleNotes()
            }
            self.tableView.reloadData()
        }
       self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func makeNavigationBarTransparent() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white]
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
        statusBarView.backgroundColor = UIColor(red: 18.0/255.0, green: 18.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        UIApplication.shared.keyWindow?.addSubview(statusBarView)
    }
    
    func populateSampleNotes() -> [NoteDescriptor] {
        
        var descriptors = [NoteDescriptor]()
        
        for i in 1...3 {
            
            // generate note's descriptor
            let descriptor = NoteDescriptor()
            descriptor.id = SimpleIDGenerator.uniqueId(hint: "note\(i)")

            // generate note's content file
            let noteFile = NoteFile(noteDescriptor: descriptor)
            let textPath = Bundle.main.path(forResource: "note\(i)", ofType: "txt")!
            noteFile.attrs = NSMutableAttributedString(string: try! String(contentsOfFile: textPath))
            noteFile.save(to: noteFile.fileURL, for: .forOverwriting, completionHandler: nil)
            
            // generate note's images
            let _ = NEFileManager.writeImageToAssetFolder(noteId: descriptor.id, image: UIImage(named: "note_\(i).jpg")!, fileName: "note_\(i)")
            descriptor.descImage1 = "note_\(i).jpg"
            
            // generate note's overview string
            descriptor.overview = (noteFile.attrs.string as NSString).substring(with: NSMakeRange(0, min(150, noteFile.attrs.length)))
            
            // save descriptor
            EditorDB.sharedInstance.saveObject(descriptor, type: .NoteDescriptor)
            
            descriptors.append(descriptor)
        }
        return descriptors
    }
    
    //MARK: - Segue Management
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == NOTE_EDITOR_SEGUE {
            if let noteEditorVC = segue.destination as? NoteEditorViewController {
                if selectedNote == nil { createNote()}
                noteEditorVC.noteDescriptor = selectedNote
                selectedNote = nil
            }
        }
    }
    
    // MARK: - Actions
    
    func createNote() {
        let descriptor = NoteDescriptor()
        descriptor.id = SimpleIDGenerator.uniqueId()
        selectedNote = descriptor
        EditorDB.sharedInstance.saveObject(descriptor, type: .NoteDescriptor)
    }
    
    func listAllNotes(with hastTag: String) {
        
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return noteDescriptors.count
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteBrowserTableViewCellID", for: indexPath) as! NoteBrowserTableViewCell
        cell.descImage1.image = nil
        cell.descImage2.image = nil
        let noteDescriptor = noteDescriptors[indexPath.row]
        let mutableAttrs = NSMutableAttributedString(string: noteDescriptor.overview)
        mutableAttrs.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle
            ], range: NSMakeRange(0, mutableAttrs.length))
        let scanningRange = SyntaxStylizer.stylizeSyntaxElements(range: NSMakeRange(0, noteDescriptor.overview.count), attrs: mutableAttrs, checkingStr: mutableAttrs.string)
        mutableAttrs.removeAttribute(.backgroundColor, range: NSMakeRange(0, mutableAttrs.length))
        if let (_, attrs) = MarkupSyntaxTruncater.instance.truncateImages(in: scanningRange, with: mutableAttrs) {
            cell.overview.attributedText = attrs
        }else {
            cell.overview.attributedText = mutableAttrs
        }
        
        if cell.overview.text!.isEmpty || cell.overview.text! == " "{
            let attrs = NSMutableAttributedString(string: "This note is empty.")
            attrs.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: ThemeCenter.theme.bodyColor, NSAttributedString.Key.paragraphStyle: ThemeCenter.theme.bodyParagraphStyle
                ], range: NSMakeRange(0, attrs.length))
            cell.overview.attributedText = attrs
        }
        
        if let path = NEFileManager.noteFromAssetFolder(id: noteDescriptor.id) {
            if !noteDescriptor.descImage1.isEmpty {
                cell.descImage1.image = UIImage(contentsOfFile: path.appendingPathComponent(noteDescriptor.descImage1).path)
            }
            if !noteDescriptor.descImage2.isEmpty {
                cell.descImage2.image = UIImage(contentsOfFile: path.appendingPathComponent(noteDescriptor.descImage2).path)
            }
        }
        return cell
    }
    
    // MARK: UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = noteDescriptors[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: NOTE_EDITOR_SEGUE, sender: self)
        //openBasicNoteEditor()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let descriptor = noteDescriptors[indexPath.row]
            let _ = NEFileManager.deleteNoteFromAssetFolder(id: descriptor.id)
            noteDescriptors.remove(at: indexPath.row)
            EditorDB.sharedInstance.deleteObject(descriptor, type: .NoteDescriptor)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - BasicNoteEditor
    
    func openBasicNoteEditor() {
        let basicNoteEditorVC = BasicNoteEditorViewController()
        if selectedNote == nil { createNote()}
        basicNoteEditorVC.noteDescriptor = selectedNote
        selectedNote = nil
        show(basicNoteEditorVC, sender: self)
    }
}

