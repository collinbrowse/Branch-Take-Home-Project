//
//  TodoDTO.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

import Foundation

struct TodoDTO: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
    var createdAt: Date? 
}
