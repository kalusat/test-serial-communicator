//
//  ContentView.swift
//  TestSerialCommunicator
//
//  Created by Niklas Kuuva on 22/09/2024.
//

import SwiftUI

struct PortSelector: View {
    @State private var availablePorts: [String] = []
    @State private var selectedPort: String? = nil
    var body: some View {
        VStack {
            Text("Select Serial Port")
                .font(.largeTitle)
                .padding()
            Picker("Serial Port", selection: $selectedPort) {
                ForEach(availablePorts, id: \.self) { port in
                    Text(port)
                        .tag(port as String?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onAppear(perform: loadSerialPorts)
        }
        .padding()
        
        if let selectedPort {
            NavigationLink(
                destination: ConnectedView(selectedPort: selectedPort),
                label: {
                    Text("Connect")
                }
            )
        }
    }
    
    func listSerialPorts() -> [String] {
        print("Listing serial ports...")
        let fileManager = FileManager.default
        let devPath = "/dev/"
        
        do {
            let devContents = try fileManager.contentsOfDirectory(atPath: devPath)
            let serialPorts = devContents.filter {$0.hasPrefix("cu.usb")}
            print("Accessed /dev/ directory")
            return serialPorts.map { devPath + $0 }
            
        } catch {
            print("Error accessing /dev/ directory: \(error)")
            return []
        }
    }
    
    func loadSerialPorts() {
        availablePorts = listSerialPorts()
        if !availablePorts.isEmpty {
            selectedPort = availablePorts.first
        }
    }
}

#Preview {
    PortSelector()
}
