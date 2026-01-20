//
//  ExamDate.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import Foundation

struct ExamDate: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let fromDate: String
    let toDate: String
}
