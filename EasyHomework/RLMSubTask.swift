//
//  RLMSubTask.swift
//  B4Grad
//
//  Created by Amritpal Singh on 9/8/18.
//  Copyright © 2018 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class RLMSubTask: Object {

    @objc dynamic var id = NSUUID().uuidString
    @objc dynamic var name = ""
    //    @objc dynamic var task = ""
    @objc dynamic var task: RLMTask?
    @objc dynamic var completed = false

    convenience init(name: String, task: RLMTask,  completed: Bool) {
        self.init()
        self.name = name
        self.task = task
        self.completed = completed
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    static func markCompleted(in realm: Realm = try! Realm(), subTask: RLMSubTask, completed: Bool, completion: @escaping(_ success: Bool) -> Void) {
        try! realm.write {

            subTask.completed = completed
            completion(true)

        }
    }

}
