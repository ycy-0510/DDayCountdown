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
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }
            .store(in: &cancellables)
            
        // Observe Significant Time Changes (Midnight, System Time change)
        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSWorkspace.didWakeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: NSNotification.Name.NSSystemClockDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStatusTitle()
            }
            .store(in: &cancellables)
    }
    
    
    func updateStatusTitle() {
        let selectedName = UserDefaults.standard.string(forKey: "selectedExamName") ?? "115 GSAT"
        
        if let exam = dateManager.dDayDates.first(where: { $0.name == selectedName }) {
            statusItem.button?.title = exam.dDayText()
        } else {
            // If empty, try fetch, otherwise show loading or default
            if dateManager.dDayDates.isEmpty {
                 dateManager.fetchDates()
                 statusItem.button?.title = "Loading..."
             } else {
                 statusItem.button?.title = "D-Day"
             }
        }
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
