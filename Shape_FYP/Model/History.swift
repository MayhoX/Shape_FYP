//
//  History.swift
//  Shape_FYP
//
//  Created by Evan Wong on 13/3/2024.
//

import Foundation


struct History: Identifiable, Codable{
    let id: String
    let date: String
    let time: String
    let calorie : String
    let aveHeatRate: String
    let push_up: Int
    let sit_up: Int
    let squat: Int
    
}
