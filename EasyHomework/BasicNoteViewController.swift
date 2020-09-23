//
//  BasicNoteViewController.swift
//  B4Grad
//
//  Created by Pham Thang on 11/27/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import NoteEditor
import RealmSwift

protocol noteEditorDelegate {
    func didTapNoteEditor(taskTitle:String,id:String,contentSet:String,cell:NoteTableViewCell)
    func deleteNoteCell(cell:NoteTableViewCell)
}

//class BasicNoteViewController: NoteEditorViewController {
class BasicNoteViewController: UIViewController {
    
    // @IBOutlet title
    var task: RLMTask!
    var selectedNote: RLMNote!
    var homeVC: HomeworkViewController?
    var cellEditingVC: CellEditingTableViewController?
    var taskManager: UIViewController? //if relevant
    var cell : NoteTableViewCell?
    var delegate : noteEditorDelegate?
    
    override func viewDidLoad() {
        self.noteDescriptor = NoteDescriptor()

        if task.note == nil {
            // create a note
            let realm = try! Realm()
            realm.beginWrite()
            task.note = RLMNote()
            do{
                try realm.commitWrite()
            } catch {
                // error while saving notes
            }
        }
        
        if selectedNote != nil{
            self.noteDescriptor!.id = selectedNote.id
            self.set = selectedNote.contentSet
        }else{
            self.noteDescriptor!.id = RLMNote().id
        }
        
        
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        let realm = try! Realm()
//        realm.beginWrite()
        
        if let title = self.noteDescriptor?.title{
      //      print(task.note?.title)
         //   task.note!.title = title
          //  task.note = nil
            
            if let cellNote = cell{
                if title == ""{
                    delegate?.deleteNoteCell(cell: cellNote)
                }else{
                    self.perform(#selector(delegates), with: nil, afterDelay: 0.3)
                  //  cellNote.noteTitleLabel.text = title
                   // delegate?.didTapNoteEditor(taskTitle: title, id: noteDescriptor.id,contentSet:set ?? "0.0", cell: cellNote)
                }
                
            }
            
          //  task.note?.id = NSUUID().uuidString
        }
    
//        do {
//            try realm.commitWrite()
//        } catch {
//             // error while saving notes
//        }
        //we comment this code due to note cell animate
       // self.cellEditingVC?.tableView.reloadData()
    }
    
    @objc func delegates() {
        if let title = self.noteDescriptor?.title{
            //      print(task.note?.title)
            //   task.note!.title = title
            //  task.note = nil
            
            if let cellNote = cell{
                if title == ""{
                    delegate?.deleteNoteCell(cell: cellNote)
                }else{
                    //  cellNote.noteTitleLabel.text = title
                    delegate?.didTapNoteEditor(taskTitle: title, id: noteDescriptor.id,contentSet:set ?? "0.0", cell: cellNote)
                }
                
            }
            
            //  task.note?.id = NSUUID().uuidString
        }
    }
}
