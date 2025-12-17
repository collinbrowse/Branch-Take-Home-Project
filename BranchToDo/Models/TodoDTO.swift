//
//  TodoDTO.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/17/25.
//

struct TodoDTO: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
