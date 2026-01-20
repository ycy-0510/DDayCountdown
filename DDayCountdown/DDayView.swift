//
//  DDayView.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import SwiftUI
import LaunchAtLogin

struct DDayView: View {
    @ObservedObject var dateManager: DateManager
    @AppStorage("selectedExamName") private var selectedExamName: String = "115 GSAT"
    @State private var now = Date()
    
    // Fallback date if nothing is found (e.g. initial load before fetch completes)
    var targetDate: Date {
        if let exam = dateManager.dDayDates.first(where: { $0.name == selectedExamName }) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: exam.fromDate) ?? Date()
        }
        return Date()
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
            
            Text("\(selectedExamName): \(formattedDate)")
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
        let today = Calendar.current.startOfDay(for: now)
        let target = Calendar.current.startOfDay(for: targetDate)
        let days = Calendar.current.dateComponents([.day], from: today, to: target).day ?? 0

        switch days {
        case 0: return "D-Day"
        case let d where d > 0: return "D-\(d)"
        default: return "D+\(-days)"
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: targetDate)
    }
}


struct DDayView_Previews: PreviewProvider {
    static var previews: some View {
        DDayView(dateManager: DateManager())
    }
}



