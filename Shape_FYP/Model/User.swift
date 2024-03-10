//
//  User.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 10/3/2024.
//

import Foundation


struct User: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let state: String
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    
    var shortName: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
    
}


extension User {
    static var example: User {
        User(id: NSUUID().uuidString, firstName: "Evan", lastName: "Wong", email: "test@gmail.com", state: "user")
    }
}
