//  DDayCountdown - A countdown application for exams and events.
//  Copyright (C) 2026 YCY
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
