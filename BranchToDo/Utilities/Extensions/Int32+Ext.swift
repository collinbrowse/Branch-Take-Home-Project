//
//  Int32+Ext.swift
//  BranchToDo
//
//  Created by Collin Browse on 12/19/25.
//

extension Int32 {
    public static func randomInt32Id() -> Int32 {
        return Int32.random(in: Int32.min...Int32.max)
    }
}
