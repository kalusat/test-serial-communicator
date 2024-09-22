//
//  ConnectedView.swift
//  TestSerialCommunicator
//
//  Created by Niklas Kuuva on 22/09/2024.
//

import SwiftUI
import SwiftSerial

struct ConnectedView: View {
    let selectedPort: String
    @State private var serialPort: SerialPort?
    @State private var receivedData: String = ""
    @State private var connectionStatus: String = "Not Connected"
    @State private var portOpen: Bool = false
    @State private var dataToSend: String = ""
    
    var body: some View {
        VStack {
            Text("Port: \(selectedPort), Status: \(connectionStatus)")
                .padding()
            Text("Data Received:")
            ScrollView {
                Text(receivedData)
                    .padding()
            }
            TextField("Enter prompt", text: $dataToSend, onCommit: sendData)
            
        }
        .padding()
        .onAppear(perform: connectToSerialPort)
        .onDisappear(perform: closeSerialPort)
    }
    
    func connectToSerialPort() {
        print("Connecting to serial port \(selectedPort)")
        serialPort = SerialPort(path: selectedPort)
        do {
            print("Opening port")
            try serialPort!.openPort()
            try serialPort!.setSettings(baudRateSetting: .symmetrical(.baud115200), minimumBytesToRead: 1)
            connectionStatus = "Connected"
            self.portOpen = true
            print("Starting data read")
            startReadingData()
            
        } catch {
            print("Error opening port: \(error)")
        }
    }
    
    func startReadingData() {
        var counter = 0
        DispatchQueue.global(qos: .background).async {
            while self.portOpen {
                print("Reading data (#\(counter))")
                counter += 1
                Task {
                    let readStream = try await serialPort?.asyncLines()
                    for await line in readStream! {
                        await MainActor.run {
                            self.receivedData += line
                        }
                    }
                }
                usleep(100000)
            }
        }
    }
    
    func sendData() {
        if !dataToSend.isEmpty {
            do {
                _ = try serialPort?.writeString(dataToSend)
                dataToSend = ""
            } catch {
                print("Failed to send data")
            }
        }
    }

    func closeSerialPort() {
        print("Closing port")
        self.portOpen = false
        serialPort?.closePort()
        print("Closed port")
    }
    
    
}

#Preview {
    ConnectedView(selectedPort: "/dev/specimen0001")
}
