//
//  NoteEditorViewController.swift
//  Note Editor
//
//  Created by Marko Rankovic on 5/24/17.
//  Edited by Thang Pham on 8/15/17.
//  Copyright © 2017 Marko Rankovic. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices


//we add this code to fetch dynamic bundle identifier so app will not crash by adding this
var bundle: Bundle {
    for budlePaths in Bundle.allFrameworks{
        if budlePaths.bundlePath.contains("NoteEditor"){
            return budlePaths
        }
    }
    return Bundle.main
}
//let bundle = Bundle(identifier: "test.EasyHomework01.NoteEditor")!  // we comment this line so it would not crash by changing identifier
let keyboardShowImage: UIImage = UIImage(named: "showkeyboard-icon", in: bundle, compatibleWith: nil)!
let keyboardShowSelectedImage: UIImage = UIImage(named: "showkeyboard-selected-icon", in: bundle, compatibleWith: nil)!
let keyboardHideImage: UIImage = UIImage(named: "hidekeyboard-icon", in: bundle, compatibleWith: nil)!
let keyboardHideSelectedImage: UIImage = UIImage(named: "hidekeyboard-selected-icon", in: bundle, compatibleWith: nil)!

open class NoteEditorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UIImagePickerControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, NoteEditorDelegate,AccessoryViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    

    // MARK: - Properties
    
    private var containerView: UIView!
    private var accessoryView: AccessoryView!
    
    private var textView: NETextView!
    private var pickerVC: UIImagePickerController!
    private var documentMenuVC: UIDocumentMenuViewController!
    private var headerSelectionVC: HeaderSelectionViewController!
    private var hyperlinkVC: HyperlinkEditionViewController!
    private var attachPreviewVC: AttachmentPreviewViewController!
    private var keyboardRect = CGRect.zero
    private var noteEditor: NoteEditor!
    public var noteDescriptor: NoteDescriptor!
    public var set : String?
    
    // MARK: Init
    
    override open func loadView() {
        super.loadView()
        accessoryView = bundle.loadNibNamed("AccessoryView", owner: nil, options: nil)![0] as? AccessoryView
        accessoryView.collectionView.register(AccessoryCollectionViewCell.self, forCellWithReuseIdentifier: "EditorToolCollectionViewCellID")
        accessoryView.delegate = self
        accessoryView.collectionView.delegate = self
        accessoryView.collectionView.dataSource = self
        accessoryView.keyboardButton.addTarget(self, action: #selector(keyboardButtonTapped), for: .touchUpInside)
        createTextView()
    }
    
    func createTextView() {
        
        // 1. Create the text storage that backs the editor
        let textStorage = NSTextStorage()
        
        // 2. Create the layout manager
        let layoutManager = EditorLayoutManager()
        
        // 3. Create a text container
        let containerSize = CGSize(width: view.bounds.width, height: CGFloat.infinity)
        let container = NSTextContainer(size: containerSize)
        container.widthTracksTextView = true
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)
        
        // 4. Create a UITextView

        textView = NETextView(frame: view.bounds, textContainer: container)

        textView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        textView.delegate = self
        
        if #available(iOS 11.0, *) {
            textView.textDragInteraction?.isEnabled = false
        } else {
            // Fallback on earlier versions
        }
        
        textView.dataDetectorTypes = []
        view.addSubview(textView)
        view.addDefaultConstraintsToView(textView)
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.keyboardDismissMode = .interactive
        textView.isSelectable = true
        textView.isEditable = false
        textView.dataDetectorTypes = []
        textView.selectedRange = NSMakeRange(0, 0)
        
        textView.inputAccessoryView  = accessoryView
        textView.keyboardDismissMode = .interactive
        textView.keyboardAppearance  = .dark
        textView.selectedRange       = NSMakeRange(0, 0)
        
        
        textView.tintColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 25)
        textView.tintColor = UIColor.lightGray

    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let infoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        infoButton.setImage(UIImage(named: "info"), for: .normal)
        infoButton.imageView?.contentMode = .scaleAspectFit
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        let shareButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        shareButton.setImage(UIImage(named: "share"), for: .normal)
        shareButton.imageView?.contentMode = .scaleAspectFill
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: infoButton), UIBarButtonItem(customView: shareButton)]
        //let infoButton = UIButton(type: .infoLight)
            //UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        
        pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        documentMenuVC = UIDocumentMenuViewController(documentTypes: [String(kUTTypeCompositeContent)], in: .import)
        documentMenuVC.delegate = self
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        headerSelectionVC = storyboard.instantiateViewController(withIdentifier: "HeaderSelectionViewController") as? HeaderSelectionViewController
        hyperlinkVC = storyboard.instantiateViewController(withIdentifier: "HyperlinkEditionViewController") as? HyperlinkEditionViewController
        attachPreviewVC = storyboard.instantiateViewController(withIdentifier: "AttachmentPreviewViewController") as? AttachmentPreviewViewController
        accessoryView.removeFromSuperview()
        ThemeCenter.setTheme(type: .Default)
        addGestureRecognizer()
        makeNavigationBarTransparent()

        /*
          load 2 navigation items
        */
      
        
        if noteDescriptor == nil {
            noteDescriptor = NoteDescriptor()
            noteDescriptor!.id = SimpleIDGenerator.uniqueId()
            //EditorDB.sharedInstance.saveObject(descriptor, type: .NoteDescriptor)
        }
        
        // Create note editor as an extended wrapper of UITextView
        noteEditor = NoteEditor(delegate: self, textView: textView)
        
        noteEditor.openFromNoteFile(noteDescriptor) { (success) in
            // open note file
            // stop activity indicator
            
            let contentSet = CGFloat(Double(self.set ?? "0.0") ?? 0.0)
            self.textView.setContentOffset(CGPoint(x: 0, y: contentSet), animated: false)
        }
        accessoryView.collectionView.reloadData()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerNotifications()
        if noteDescriptor.overview.isEmpty {
            self.tapAt(3)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let barHeight = navigationController!.navigationBar.bounds.height
        textView.scrollIndicatorInsets = UIEdgeInsets(top: barHeight, left: 0, bottom: 0, right: 0)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var value = 0.0
        if textView.contentOffset.y > 20.0{
            value = Double(textView.contentOffset.y)
        }else{
            value = Double(textView.contentOffset.y)
        }
        set = "\(value)"
        noteEditor.saveToNoteFile(completion: nil)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterNotifications()
    }
    
    func makeNavigationBarTransparent() {
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    // MARK: - ScrollView Delegates
    
    private func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if(scrollView.contentOffset.y <= -20 ) {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            }
        })
    }
    
    // MARK: - TextView Delegates

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let selectedRange = self.textView.selectedRange
        //DispatchQueue.main.async {
            self.noteEditor.changeText(in: range, replacementText: text, selectedRange: selectedRange)
        //}
        return false
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        if self.textView.selectedTextRange == nil {
            DispatchQueue.main.async {
                self.textView.resignFirstResponder()
            }
        }
    }

    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return false
    }
    
    func handleAttachmentLinkURL(url: URL) -> Bool {

        if let scheme = url.scheme {
            if scheme == "file" {
                attachPreviewVC.fileUrl = url
                DispatchQueue.main.async {
                    self.present(self.attachPreviewVC, animated: true, completion: nil)
                }
                
                return false
            }else if scheme == "NoteEditor" {
                if url.host! == "x-callback-url" {
                    DispatchQueue.main.async {
                        self.parseXCallbackURL(path: url.path)
                    }
                    return false
                }
            }
        }
        if url.scheme == nil {
            if let wrappedURL = URL(string: "http://\(url)") {
                DispatchQueue.main.async {
                    UIApplication.shared.openURL(wrappedURL)
                }
                return false
            }
        }
        DispatchQueue.main.async {
            UIApplication.shared.openURL(url)
        }
        return true
    }
    
    func parseXCallbackURL(path: String) {
        
        if path == "/hashtag" {
            // dispatch hashtag action at (location
        }else if path == "/hyperlink" {
            noteEditor.doEditHyperLink(selectedRange: self.textView.selectedRange)
        }else if path == "/header" {
            noteEditor.doEditHeader(selectedRange: self.textView.selectedRange)
        }else if path == "/checkbox" {
            noteEditor.crossLine(selectedRange: self.textView.selectedRange)
        }
    }
    
    // MARK: - Notifications
    
    func registerNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidChangeFrame(notification:)), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Gesture Recognizer
    
    func addGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        tapRecognizer.delegate = self
        textView.addGestureRecognizer(tapRecognizer)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
            return true
        }
        return false
    }
    
    var isKeyboardShown = false
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        print(textView.contentOffset.y)
        if textView.attributedText.string.isEmpty {
            if isKeyboardShown {
                isTextViewSelectable = false
            }else {
                textView.isEditable = true
                self.textView.becomeFirstResponder()
            }
            return
        }
        let touchPoint = recognizer.location(in: textView)
        if let textRange = textView.characterRange(at: touchPoint) {
            let  idx = textView.offset(from: textView.beginningOfDocument, to: textRange.end)
            tapAt(idx)
        }
    }
    
    func tapAt(_ idx: Int)
    {
            var matchURL: URL? = nil
            if idx < textView.textStorage.length - 1 {
                textView.attributedText.enumerateAttribute(NSAttributedString.Key.link, in: NSMakeRange(idx, 1), options:.longestEffectiveRangeNotRequired, using: { (linkURL, range, _) in
                    if let url = linkURL as? URL {
                        matchURL = url
                    }
                    
                })
            }
            if matchURL == nil {
                if textView.isEditable == false {
                    if isKeyboardShown {
                        isTextViewSelectable = false
                    }else {
                        
                        UIView.animate(withDuration: 0.8) {
                            self.textView.isEditable = true
                            self.textView.selectedRange = NSMakeRange(idx, 0)
                            
                        /*    let cursorRect = self.textView.caretRect(for: self.textView.selectedTextRange!.start)
                            let cursorPoint = CGPoint(x: cursorRect.midX, y: cursorRect.midY)
                            let containerHeight = self.textView.frame.size.height
                            let barHeight = self.navigationController!.navigationBar.bounds.height
                            var offsetY = cursorPoint.y - (containerHeight  - (self.keyboardRect.size.height + KEYBOARD_OFFSET_HEIGHT))
                            if offsetY > -containerHeight/2 {
                                offsetY = max(offsetY, -(20 + barHeight))
                                if self.textView.contentOffset.y != offsetY {
                                    self.textView.setContentOffset(CGPoint(x:self.textView.contentOffset.x, y:offsetY), animated: true)
                                }
                            }*/
                            
                        }
//                        UIView.animate(withDuration: 0.3) {
                            if self.textView.text == ""{
                                self.textView.becomeFirstResponder()
                            }
//                            self.textView.becomeFirstResponder()
//                        }
                        
                    }
                }
            }else {
                self.textView.selectedRange = NSMakeRange(idx, 0)
                let _ = self.handleAttachmentLinkURL(url: matchURL!)
            }
    }

    // MARK: - Keyboard Event Handlers
    
    @objc func handleKeyboardDidChangeFrame(notification: Notification) {
        let keyboardRectAsObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        keyboardRectAsObject.getValue(&keyboardRect)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        if textView.isEditable {
            let keyboardRectAsObject = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
            keyboardRectAsObject.getValue(&keyboardRect)
            if keyboardRect != CGRect.zero {
                textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (self.keyboardRect.size.height + KEYBOARD_OFFSET_HEIGHT), right: 0)
            }
            accessoryView.keyboardButton.setImage(keyboardHideImage, for: .normal)
            accessoryView.keyboardButton.setImage(keyboardHideSelectedImage, for: .selected)
        }else {
            accessoryView.keyboardButton.setImage(keyboardShowImage, for: .normal)
            accessoryView.keyboardButton.setImage(keyboardShowSelectedImage, for: .selected)
        }
    }
    
    @objc func handleKeyboardDidShow(notification: Notification) {
        isKeyboardShown = true
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        guard navigationController != nil else { return }
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc func handleKeyboardDidHide(notification: Notification) {
        isKeyboardShown = false
        if textView.isEditable {
            if !textView.isFirstResponder {
                self.textView.isEditable = false
            }
            self.textView.selectedTextRange = nil
        }
        if isTextViewSelectable == false && textView.selectedTextRange != nil {
            isTextViewSelectable = true
            textView.isEditable = true
            textView.becomeFirstResponder()
        }
    }
    
    //MARK: - Actions
    var isTextViewSelectable = true
    @objc func keyboardButtonTapped() {
        if textView.isEditable {
            self.textView.resignFirstResponder()
        }else {
            isTextViewSelectable = false
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0)
            UIView.setAnimationDelay(0.0)
            self.textView.resignFirstResponder()
            UIView.commitAnimations()
        }
    }
    
    @objc func shareButtonTapped() {
        if let url = NoteExporter.sharedInstance.export(attrs: textView.attributedText, to: .rtf) {
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func infoButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let infoVC = storyboard.instantiateViewController(withIdentifier: "NoteInfoViewControllerID") as! NoteInfoViewController
        noteEditor.saveToNoteFile(completion: nil)
        infoVC.noteFile = noteEditor.noteFile
        navigationController?.pushViewController(infoVC, animated: true)
    }

    
    func accessoryViewDoEditAction(_ index:Int) {
        noteEditor.doAction(at: index, selectedRange: self.textView.selectedRange)
    }
    
    //MARK: - Segue Management
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == INFO_SEGUE {
            if let infoVC = segue.destination as? NoteInfoViewController {
                noteEditor.saveToNoteFile(completion: nil)
                infoVC.noteFile = noteEditor.noteFile
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noteEditor.editActions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = accessoryView.collectionView.dequeueReusableCell(withReuseIdentifier: "EditorToolCollectionViewCellID", for: indexPath) as! AccessoryCollectionViewCell
        
        if cell.button == nil {
            cell.button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            cell.button.addTarget(accessoryView, action: #selector(accessoryView.doEditAction(_:)), for: .touchUpInside)
            cell.button.setBackgroundImage(UIImage(named: "editbutton_background", in: bundle, compatibleWith: nil), for: .normal)
            cell.button.setBackgroundImage(UIImage(named: "editbutton_selected_background", in: bundle, compatibleWith: nil), for: .selected)
            cell.addSubview(cell.button)
        }
            cell.button.setImage(noteEditor.editActions[indexPath.item].normalImage, for: .normal)
            cell.button.setImage(noteEditor.editActions[indexPath.item].selectedImage, for: .selected)
            cell.button.isSelected = false
        
        cell.isSelected = false
        return cell
    }
    
    //MARK: - UICollectionViewDelegate

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false 
    }
    
    // MARK: - NoteEditor Delegates
    func requestUserInputHeaderType(sender: NoteEditor, completion: ((TextHeaderType) -> Void)?) {
        headerSelectionVC.completion = completion
        presentHeaderSelectionVC()
    }
    
    @objc func presentHeaderSelectionVC() {
        self.textView.isEditable = false
        present(headerSelectionVC, animated: true) {
            self.textView.isEditable = false
        }
    }
    
    func requestUserInputPhoto(sender: NoteEditor, completion: ((String?) -> Void)?) {
        presentImagePicker(completion: completion)
    }
    
    func requestUserInputHyperlink(sender: NoteEditor, preemptedTitle: String, preemptedLink: String, completion: ((String?, String?) -> Void)?) {
        hyperlinkVC.completion = completion
        presentHyperlinkVC(preemptedTitle:preemptedTitle, preemptedLink: preemptedLink)
    }
    
    func presentHyperlinkVC(preemptedTitle: String, preemptedLink: String) {
        textView.isEditable = false
        hyperlinkVC.reset(preemptedTitle, preemptedLink)
        present(hyperlinkVC, animated: true) {
            self.textView.isEditable = false
        }
    }
    
    func requestUserInputAttachedFile(sender: NoteEditor, completion: ((String?) -> Void)?) {
        presentDocumentMenu(completion: completion)
    }
    
    // MARK: - Media Picker
    
    func presentImagePicker(completion: ((String?) -> ())?) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera(completion: completion)
        }
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.openPhotoLibrary(completion: completion)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        let selectedRange = self.textView.selectedRange
        present(alert, animated: true) {
            self.textView.selectedRange = selectedRange
        }
    }
    
    func openCamera(completion: ((String?) -> ())?) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerVC.sourceType = UIImagePickerController.SourceType.camera
            pickerVC.allowsEditing = false
            pickerVC.completion = completion
            present(pickerVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning", message: "Your device doesn't have a camera", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotoLibrary(completion: ((String?) -> ())?) {
        
        pickerVC.sourceType = .photoLibrary
        pickerVC.allowsEditing = false
        pickerVC.completion = completion
        present(pickerVC, animated: true, completion: nil)
    }

    //MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        /*var pickedImage = info[UIImagePickerController.InfoKey.originalImage] as UIImage
        if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
            let asset = result.firstObject
            if let filename = asset?.value(forKey: "filename") as? String {
                let name = (filename as NSString).deletingPathExtension
                if pickedImage.size.width > 240 {
                    pickedImage = pickedImage.resizeImage(widthSize: 240)
                }
                if NEFileManager.writeImageToAssetFolder(noteId: noteDescriptor.id, image: pickedImage, fileName: name) {
                    dismiss(animated: true, completion: {
                        picker.completion?((name as NSString).appendingPathExtension("jpg"))
                    })
                    return
                }
            }
        }*/
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: File Picker
    
    func presentDocumentMenu(completion: ((String?) -> ())?) {
        documentMenuVC.modalPresentationStyle = .formSheet
        documentMenuVC.completion = completion
        let selectedRange = self.textView.selectedRange
        self.present(documentMenuVC, animated: true){
            self.textView.selectedRange = selectedRange
        }
    }
    
    // MARK: DocumentMenu Delegates
    
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.completion = documentMenu.completion
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    public func documentMenuWasCancelled(_ documentMenu: UIDocumentMenuViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: DocumentPicker Delegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let fileName = url.lastPathComponent
        if NEFileManager.moveFileToAssetFolder(noteId: self.noteDescriptor.id, sourceUrl: url, fileName: fileName) {
            controller.completion?(fileName)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
}

