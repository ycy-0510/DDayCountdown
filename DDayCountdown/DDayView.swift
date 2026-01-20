//
//  DDayView.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import SwiftUI
import LaunchAtLogin

struct DDayView: View {
    var targetDate: Date
    var name = "GSAT"

    @State private var now = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    var body: some View {
        VStack {
            Text(formattedDDay)
                .font(.largeTitle)
                .padding(.top)
            Text("\(name): \(formattedDate)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
            Divider()
            // Toggle for auto-launch
            LaunchAtLogin.Toggle()
             .padding(.horizontal)
            
            Divider()
                       
           Button("Quit") {
               NSApp.terminate(nil)
           }
           .buttonStyle(BorderlessButtonStyle())
        }
        .frame(width: 150)
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
        // Replace this with any date you want to test
        DDayView(targetDate: Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 16))!)
    }
}
