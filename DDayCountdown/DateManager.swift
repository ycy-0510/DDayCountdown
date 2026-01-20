//
//  DateManager.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import Foundation
import Combine

class DateManager: ObservableObject {
    @Published var dDayDates: [ExamDate] = []
    
    private let remoteURL = URL(string: "https://raw.githubusercontent.com/ycy-0510/DDayCountdown/refs/heads/main/Date.json")!
    
    init() {
        loadDates()
    }
    
    func fetchDates() {
        let request = URLRequest(url: remoteURL)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                print("Error fetching dates: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let dates = try JSONDecoder().decode([ExamDate].self, from: data)
                DispatchQueue.main.async {
                    self.dDayDates = dates
                    self.saveDatesToDocuments(data)
                }
            } catch {
                print("Error decoding dates: \(error)")
            }
        }.resume()
    }
    
    private func saveDatesToDocuments(_ data: Data) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("Date.json")
        do {
            try data.write(to: fileURL)
            print("Dates saved to \(fileURL)")
        } catch {
            print("Error saving dates: \(error)")
        }
    }
    
    private func loadDates() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("Date.json")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                dDayDates = try JSONDecoder().decode([ExamDate].self, from: data)
                print("Loaded dates from local cache.")
            } catch {
                print("Error loading local dates: \(error)")
                fetchDates() // Fallback to fetch if local load fails
            }
        } else {
            fetchDates()
        }
    }
}
