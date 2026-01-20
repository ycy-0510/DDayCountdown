//
//  AppDelegate.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let popover = NSPopover()
    var timer: Timer?
    let targetDate = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 16))!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
              updateStatusTitle()

              if let button = statusItem.button {
                  button.action = #selector(togglePopover(_:))
                  button.target = self
              }

              // Set up popover content
              let contentView = DDayView(targetDate: targetDate)
              popover.contentSize = NSSize(width: 135, height: 80)
              popover.contentViewController = NSViewController()
              popover.contentViewController?.view = NSHostingView(rootView: contentView)
              popover.behavior = .transient

              // Start timer
              timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                  self.updateStatusTitle()
              }
    }
    
    
    func updateStatusTitle() {
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
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
