//
//  TestSerialCommunicatorApp.swift
//  TestSerialCommunicator
//
//  Created by Niklas Kuuva on 22/09/2024.
//

import SwiftUI

@main
struct TestSerialCommunicatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PortSelector()
            }
        }
    }
}
