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

import SwiftUI
import LaunchAtLogin

struct DDayView: View {
    @ObservedObject var dateManager: DateManager
    @AppStorage("selectedExamName") private var selectedExamName: String = "115 AST"
    @State private var now = Date()
    
    // Fallback date if nothing is found (e.g. initial load before fetch completes)
    var currentExam: ExamDate? {
        dateManager.dDayDates.first(where: { $0.name == selectedExamName })
    }
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // Picker for selecting the exam
            Picker("Exam", selection: $selectedExamName) {
                ForEach(dateManager.dDayDates) { exam in
                    Text(exam.name).tag(exam.name)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.top)
            
            Text(formattedDDay)
                .font(.largeTitle)
                .padding(.vertical, 5)
            
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
            
            Divider()
            
            LaunchAtLogin.Toggle()
                .padding(.horizontal)
            
            Divider()
            
            HStack {
                Button("Reload") {
                    dateManager.fetchDates()
                }
                
                Button("About") {
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
                
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
            .buttonStyle(BorderlessButtonStyle()) // Ensure buttons look good in menu bar
        }
        .frame(width: 200) // Increased width slightly to accommodate Picker
        .onReceive(timer) { input in
            now = input
        }
        .padding()
    }

    var formattedDDay: String {
        guard let exam = currentExam else { return "..." }
        return exam.dDayText(relativeTo: now)
    }

    var formattedDate: String {
        guard let exam = currentExam else { return "" }
        if exam.fromDate == exam.toDate {
            return "\(exam.name): \(exam.fromDate)"
        } else {
            return "\(exam.name): \(exam.fromDate) ~ \(exam.toDate)"
        }
    }
}


struct DDayView_Previews: PreviewProvider {
    static var previews: some View {
        DDayView(dateManager: DateManager())
    }
}



