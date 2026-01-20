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
    
    func dDayText(relativeTo referenceDate: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let start = formatter.date(from: fromDate),
              let end = formatter.date(from: toDate) else {
            return "Error"
        }
        
        let today = Calendar.current.startOfDay(for: referenceDate)
        let startDate = Calendar.current.startOfDay(for: start)
        let endDate = Calendar.current.startOfDay(for: end)
        
        // Before range
        if today < startDate {
            let days = Calendar.current.dateComponents([.day], from: today, to: startDate).day ?? 0
            return "D-\(days)"
        }
        // After range
        else if today > endDate {
            let days = Calendar.current.dateComponents([.day], from: today, to: endDate).day ?? 0
            return "D+\(-days)" // days is negative here
        }
        // During range
        else {
            return "D-Day"
        }
    }
}
