//
//  AddCourseTableViewController.swift
//  B4Grad
//
//  Created by Anthony Giugno on 2017-04-18.
//  Copyright © 2017 Anthony Giugno. All rights reserved.
//

import UIKit
import RealmSwift

class AddCourseTableViewController: UITableViewController, UITextFieldDelegate {
    
    enum CourseEditingMode: String {
        case Edit = "Edit", Create = "Create"
        //Edit - for editing an already created course.
        //Create - for creating a new course.
    }

    var array = [ScheduleRowContent(identifier: "CourseNameCell"), ScheduleRowContent(identifier: "CourseCodeCell"), ScheduleRowContent(identifier: "CreateCell")]
    var coursesVC: CoursesViewController!
    var course: RLMCourse!
    var mode = CourseEditingMode.Edit
    
    var coursesQuery: Results<RLMCourse> {
        let realm = try! Realm()
        return realm.objects(RLMCourse.self).sorted(byKeyPath: "createdDate", ascending: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (mode == .Create) {
            self.course = RLMCourse(courseCode: nil, courseName: "", facultyName: nil, universityName: nil)
            self.array[0].optionString1 = "DefaultFaculty" //data.optionString1 stores facultyImageView.image's name.
        } else if (mode == .Edit) {
            self.title = self.course.courseTitle()
            self.array[0].name = self.course.courseName
            if (self.course.facultyName != nil) {
                self.array[0].optionString1 = self.course.facultyName
            } else {
                self.array[0].optionString1 = "DefaultFaculty"
            }
            self.array[1].name = self.course.courseCode
            self.array.remove(at: 2)
        }
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CourseNameTableViewCell
        cell?.textField.becomeFirstResponder()
    }
    
    
    @IBAction func addCourseButtonTapped(_ sender: Any) {
        
        //Original behaviour below.
        //self.show(self.storyboard!.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController, sender: sender)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.tag == 0 && self.array[0].optionBool1 == false) {
            let dynamicFacultyName: String? = self.dynamicallyPickFacultyIcon(courseName: textField.text!)
            let courseNameCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CourseNameTableViewCell
            if (dynamicFacultyName != nil) {
                self.array[textField.tag].optionString1 = dynamicFacultyName
                self.tableView.beginUpdates()
                courseNameCell.facultyButton.setImage(UIImage(named: dynamicFacultyName!), for: .normal)
                self.tableView.endUpdates()
            } else {
                self.array[textField.tag].optionString1 = "DefaultFaculty"
                self.tableView.beginUpdates()
                courseNameCell.facultyButton.setImage(#imageLiteral(resourceName: "DefaultFaculty"), for: .normal)
                self.tableView.endUpdates()
            }
        }

        let newString = textField.text
        self.array[textField.tag].name = newString
        /*if (self.mode == .Edit) {
            //Save course object.
            let realm = try! Realm()
            realm.beginWrite()
            if (textField.tag == 0) {
                self.course.courseName = newString
            } else if (textField.tag == 1) {
                self.course.courseCode = newString
            }
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
            }
            //update title
            self.title = self.course.courseTitle()
            //reload the cell on previous VC.
            self.coursesVC.tableView.reloadData()
            //reload homeVC
            self.coursesVC.homeVC.tableView.reloadData()
        }*/
    }
    
    //Unintended behaviour of this method is that it ensures that textfields always have atleast one character. :)
    /*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newString = ""
        if (textField.text != nil) {
            newString = textField.text! + string
            self.array[textField.tag].name = newString
        } else {
            newString = textField.text! + string
            self.array[textField.tag].name = newString
        }
        if (self.mode == .Edit) {
            //Save course object.
            let realm = try! Realm()
            realm.beginWrite()
            if (textField.tag == 0) {
                self.course.courseName = newString
            } else if (textField.tag == 1) {
                self.course.courseCode = newString
            }
            do {
                try realm.commitWrite()
            } catch let error {
                let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
                errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
                self.present(errorVC, animated: true, completion: nil)
                return true
            }
            //update title
            self.title = self.course.courseTitle()
            //reload the cell on previous VC.
            self.coursesVC.tableView.reloadData()
            //reload homeVC
            self.coursesVC.homeVC.tableView.reloadData()
        }
        return true
    }*/
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (self.mode == .Edit) {
            let realm = try! Realm()
            realm.beginWrite()
            self.course.facultyName = self.dynamicallyPickFacultyIcon(courseName: self.array[0].name!)
            do {
                try realm.commitWrite()
            } catch let error {}
        }
        if (textField.tag == 0) {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! CourseCodeTableViewCell
            cell.textField.becomeFirstResponder()
            return false
        }
        if (textField.tag == 1) {
            if (self.mode == .Create) {
                let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! UITableViewCell
                self.createCourse()
            }
            textField.resignFirstResponder()
            return true
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.array[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: self.array[indexPath.row].identifier, for: indexPath)
        if let courseNameCell = cell as? CourseNameTableViewCell {
            courseNameCell.textField.delegate = self
            courseNameCell.textField.tag = 0
            courseNameCell.textField.text = data.name
            courseNameCell.facultyButton.setImage(UIImage(named: data.optionString1!), for: .normal) //data.optionString1 stores
            courseNameCell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        if let courseCodeCell = cell as? CourseCodeTableViewCell {
            courseCodeCell.textField.delegate = self
            courseCodeCell.textField.tag = 1
            courseCodeCell.textField.text = data.name
            courseCodeCell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        return cell
    }
    
    var selectedCell: UITableViewCell?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        let data = self.array[indexPath.row]
        if (data.identifier == "CreateCell") {
            self.selectedCell = cell
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.createCourse()
        }
    }
    
    func createCourse() {
        self.selectedCell?.isUserInteractionEnabled = false
        if (self.array[0].name == nil || self.array[0].name == "") {
            let errorVC = UIAlertController(title: "Oops..", message: "Please provide a Course Name.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            self.selectedCell?.isUserInteractionEnabled = true
            return
        }
        if (self.array[1].name == nil || self.array[1].name == "") {
            self.course.courseCode = nil
        } else {
            self.course.courseCode = self.array[1].name
        }
        self.course.courseName = self.array[0].name!
        self.course.facultyName = self.array[0].optionString1!
        
        var staticColors = [1, 2, 3, 4, 5]
        for currentCourse in self.coursesQuery {
            if (staticColors.contains(currentCourse.colorStaticValue)) {
                staticColors.removeObject(object: currentCourse.colorStaticValue)
            }
        }
        //Automatically select color based on what's available.
        if (staticColors.count > 0) {
            self.course.colorStaticValue = staticColors.first!
            if (self.course.colorStaticValue == 1) {
                self.course.color = RLMColor(color: UIColor(red: 43/255, green: 132/255, blue: 210/255, alpha: 1))
            }
            if (self.course.colorStaticValue == 2) {
                self.course.color = RLMColor(color: UIColor(red: 44/255, green: 197/255, blue: 94/255, alpha: 1))
            }
            if (self.course.colorStaticValue == 3) {
                self.course.color = RLMColor(color: UIColor(red: 237/255, green: 186/255, blue: 16/255, alpha: 1))
            }
            if (self.course.colorStaticValue == 4) {
                self.course.color = RLMColor(color: UIColor(red: 222/255, green: 106/255, blue: 27/255, alpha: 1))
            }
            if (self.course.colorStaticValue == 5) {
                self.course.color = RLMColor(color: UIColor(red: 223/255, green: 52/255, blue: 46/255, alpha: 1))
            }
        } else {
            self.course.colorStaticValue = 0
            self.course.color = RLMColor(color: UIColor(red: 67/255, green: 67/255, blue: 67/255, alpha: 1))
        }
        
        let repeatingLectureSchedule = RLMRepeatingSchedule(schedule: "Weekly",type: "Lecture", course: self.course, location: nil)
        repeatingLectureSchedule.builtIn = true
        let repeatingLabSchedule = RLMRepeatingSchedule(schedule: "Weekly", type: "Lab", course: self.course, location: nil)
        repeatingLabSchedule.builtIn = true
        let repeatingTutorialSchedule = RLMRepeatingSchedule(schedule: "Weekly",type: "Tutorial", course: self.course, location: nil)
        repeatingTutorialSchedule.builtIn = true
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(self.course)
        realm.add([repeatingLectureSchedule, repeatingLabSchedule, repeatingTutorialSchedule])
        do {
            try realm.commitWrite()
        } catch let error {
            let errorVC = UIAlertController(title: "Oops..", message: "Error: " + error.localizedDescription + " This is a rare issue.", preferredStyle: .alert)
            errorVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in }))
            self.present(errorVC, animated: true, completion: nil)
            self.selectedCell?.isUserInteractionEnabled = true
            return
        }
        self.coursesVC.tableView.reloadData()
        self.navigationController!.popViewController(animated: true)
    }


    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: { })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //Returns nil if no faculty could be determined.
    func dynamicallyPickFacultyIcon(courseName: String) -> String? {
        
        
        //if (courseName.containsIgnoringCase("Intercultural Communications")) {
            
        //}
        
        for identificationArray in self.defaultFacultiesArray {
            for identifier in identificationArray {
                if (courseName.containsIgnoringCase(identifier)) {
                    return identificationArray[0]
                }
            }
        }
        return nil
    }
    
    //assume value 2 unless stated otherwise
    let defaultFacultiesArray = [["Intercultural Communications"],
                                 //2: ["Nursing", "Caring"],
                                 ["Culinary Arts", "Culinary", "Cooking", "Cook", "Food", "Foods", "Food Science", "Nutrition", "Chef"],
                                 ["Persian"],
                                 ["Philosophy", "Philosophical", "Moral"],
                                 ["Political Science", "Politics", "Political", "Politician", "Politicians"],
                                 ["Scholars Electives", "Scholars", "Scholarly"],
                                 ["Actuarial Science", "Actuarial"],
                                 ["American Studies", "American"],
                                 ["Anatomy and Cell Biology"],
                                 ["Anthropology", "Anthropological"],
                                 ["Applied Mathematics"],
                                 ["Arabic"],
                                 ["Arts and Humanities", "Art", "Artistic", "Visual Art"],
                                 ["Astronomy", "Astronomical", "Space", "Planets", "Stars", "Moon", "Black Hole", "Black Holes"],
                                 ["Biochemistry", "Biochemical"],
                                 ["Biology", "Biological", "Biostatistics"],
                                 ["Business Administration", "Business", "Administration"],
                                 ["Calculus"],
                                 ["Chemical and Biochemical Engineering"],
                                 ["Chemistry", "Chemical", "Chemical Biology"],
                                 ["Civil and Environmental Engineering"],
                                 ["Classical Studies"],
                                 ["Communication Sciences and Disorders", "Disorders"],
                                 ["Comparative Literature and Culture", "Literature", "Poetry", "Poet"],
                                 ["Computer Science", "Software Engineering", "Software", "Internet", "Information Systems", "Apps", "Programming", "Assembly", "Data", "Computing", "Computational", "Algorithms", "Artificial Intelligence", "Operating Systems", "Object-Oriented", "Databases", "Cryptography", "Game"],
                                 ["Dance", "Dancing"],
                                 ["Civics", "Career", "Citizen", "Citizenship"],
                                 ["Digitial Humanities", "Digital Communication"],
                                 ["Earth Sciences", "Earth", "Geography", "Geographical", "Geographic", "Physical Geography", "Geographer", "Geographics", "Tourism", "Travel", "Cities", "City", "World"],
                                 ["Economics", "Economical", "Economic"],
                                 ["Education", "Educational"],
                                 ["Electrical and Computer Engineering", "Computer", "Electrical", "Transistors"],
                                 ["Engineering Science", "Engineering", "Engineer"],
                                 ["English", "Shakespeare", "Shakespearean"],
                                 ["Environmental Science", "Environment", "Environmental"],
                                 ["Epidemiology", "Epidemiology and Biostatistics", "Epidemiological"],
                                 ["Film Studies", "Film", "Movies", "Disney"],
                                 ["Financial Modelling"],
                                 ["First Nations Studies", "First Nations", "Aboriginal"],
                                 ["French"],
                                 ["German"],
                                 ["Greek"],
                                 ["Green Process Engineering"],
                                 ["Health Sciences", "Health", "Anatomy", "Nursing", "Caring"],
                                 ["Hindi"],
                                 ["History", "Historical"],
                                 ["International Relations"],
                                 ["Italian"],
                                 ["Japanese"],
                                 ["Jewish Studies", "Jewish", "Israeli"],
                                    ["Kinesiology", "Exercise", "Sport", "Physical", "Human Movement", "Athletic", "Biomechanics", "Basketball", "Golf", "Football", "Hockey", "Soccer", "Fitness", "Judo", "Rugby", "Sailing", "Olympic"],
                                 ["Korean"],
                                 ["Latin"],
                                 ["Canadian Studies", "Canada", "Canadian"],
                                 ["Law", "Legal", "Trademark", "Trademarks", "Justice", "Court", "Judiciary"],
                                 ["Linguistics", "Language", "Languages"],
                                 ["Management and Organizational Studies", "Management", "Organization", "Business", "Marketing", "Financial", "Finance", "Accounting", "Marketable", "Entrepreneurship", "Entrepreneur", "Enterprising", "Enterprise", "Corporate", "Corporation", "Taxes", "Venture"],
                                 ["Materials Science", "Materials", "Material"],
                                 ["Mathematics", "Math"],
                                 ["Mechanical and Materials Engineering", "Mechanical", "Workshop", "Tooling", "Craftsmanship"],
                                 ["Mechatronic Systems Engineering"],
                                 ["Media, Information and Technoculture", "Media", "News", "Multimedia", "Culture", "Pop Culture"],
                                 ["Medical Biophysics"],
                                 ["Medical Health Informatics"],
                                 ["Medical Sciences", "Medical"],
                                 ["Medieval Studies", "Medieval"],
                                 ["Microbiology and Immunology"],
                                 ["Music", "Musical"],
                                 ["Neuroscience"],
                                 ["Pathology and Toxicology", "Pathology", "Pathological"],
                                 //2: ["Pathology", "Pathological"]],
                                 ["Pharmacology", "Pharmacological"],
                                 ["Physics", "Force", "Forces"],
                                 ["Physiology", "Physiological"],
                                 ["Polish"],
                                 ["Portuguese", "Portugese"],
                                 ["Psychology", "Psychological", "Behavioural"],
                                 ["Rehabilitation Sciences", "Rehabilitation"],
                                 ["Russian"],
                                 ["Science", "Research"],
                                 ["Social Science"],
                                 ["Sociology", "Social", "Sociological"],
                                 //2: ["Software Engineering", "Software"]],
                                 ["Spanish"],
                                 ["Religious Studies", "Religion", "Theology", "Theological", "Cathloic", "Christian", "Christianity", "Jesus", "God", "Church", "New Testament", "Hebrew Bible", "Bible", "Spiritual", "Angels", "Angel", "Belief"],
                                 ["Speech"],
                                 ["Statistical Sciences", "Statistics", "Statistical"],
                                 ["Theatre Studies", "Theatre"],
                                 ["Transitional Justice"],
                                 ["Visual Arts History"],
                                 ["Visual Arts Studio"],
                                 ["Women's Studies", "Women", "Woman"],
                                 ["Writing"]]
                                //"Writing", 3
                                //"Statistical Sciences", 1
                                //"Science", 1
                                //"Social", 1
                                //"History", 3
                                //"Mathematics", 1
                                //"Law", 3
                                //"Health Sciences", 1
                                //"Chemistry", 1
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is FacultyCollectionViewController) {
            let facultyIconVC = segue.destination as! FacultyCollectionViewController
            facultyIconVC.addCourseVC = self
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
