//
//  FacultiesArray.swift
//  B4Grad
//
//  Created by Sunil Zalavadiya on 15/01/19.
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import Foundation

class FacultyDataModel {
    static let shared = FacultyDataModel()
    
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
}
