//
//  AppDelegate.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import Cocoa
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let popover = NSPopover()
    var timer: Timer?
    var dateManager = DateManager()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Initial update
        updateStatusTitle()

        if let button = statusItem.button {
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Set up popover content
        let contentView = DDayView(dateManager: dateManager)
        popover.contentSize = NSSize(width: 200, height: 160)
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: contentView)
        popover.behavior = .transient

        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateStatusTitle()
        }
        
        // Observe Data Changes (Fetch complete)
        dateManager.$dDayDates
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }
            .store(in: &cancellables)
            
        // Observe Selection Changes (User picks new exam)
        // Note: AppStorage writes to UserDefaults.
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }
            .store(in: &cancellables)
    }
    
    
    func updateStatusTitle() {
        let selectedName = UserDefaults.standard.string(forKey: "selectedExamName") ?? "115 GSAT"
        
        // Find the date for the selected exam
        var targetDate = Date()
        if let exam = dateManager.dDayDates.first(where: { $0.name == selectedName }) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            targetDate = formatter.date(from: exam.fromDate) ?? Date()
        } else {
            // If main list is empty (not loaded yet) or not found, try to ensure we have something or wait
            // For now, if we can't find it, we might display "Loading" or just "D-Day"
            // Let's reload if empty?
             if dateManager.dDayDates.isEmpty {
                 dateManager.fetchDates()
             }
        }
        
        // Calculate Days
        let today = Calendar.current.startOfDay(for: Date())
        let target = Calendar.current.startOfDay(for: targetDate)
        let days = Calendar.current.dateComponents([.day], from: today, to: target).day ?? 0

        let title: String
        switch days {
        case 0: title = "D-Day"
        case let d where d > 0: title = "D-\(d)"
        default: title = "D+\(-days)"
        }

        statusItem.button?.title = title
    }

    @objc func togglePopover(_ sender: Any?) {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Refresh title on open just in case
                updateStatusTitle()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
