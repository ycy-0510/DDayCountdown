//
//  DDayCountdownApp.swift
//  DDayCountdown
//
//  Created by Cheng Yan Yang on 2025/6/3.
//

import SwiftUI

@main
struct DDayCountdownApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // no settings window needed
        }
    }
}
