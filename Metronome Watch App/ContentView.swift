//
//  ContentView.swift
//  Metronome Watch App
//
//  Created by Kaushik Mahadevan on 7/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var beatsPerMinute: Double = 60
    @State private var isRunning: Bool = false
    @State private var timer: Timer?
    @State private var session: WKExtendedRuntimeSession?
    
    var body: some View {
        VStack {
            Text("BPM: \(Int(beatsPerMinute))")
            Button(action: {
                enableMetronome()
            }) {
                Text(isRunning ? "Stop" : "Start").frame(width: 100)
            }.buttonStyle(.borderedProminent)
        }.focusable(true)
            .digitalCrownRotation(
                $beatsPerMinute,
                from: 20,
                through: 200,
                by: 1,
                sensitivity: .medium,
                isHapticFeedbackEnabled: true
            ).onChange(of: beatsPerMinute) {
                if isRunning {
                    restartTick()
                }
            }
        .padding()
    }
    private func startTick() {
        let interval = 60.0 / beatsPerMinute
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.start)
        }
        
    }
    private func restartTick() {
        timer?.invalidate()
        startTick()
    }
    private func enableMetronome() {
        isRunning.toggle()
        if isRunning {
            session?.start()
            startTick()
        } else {
            timer?.invalidate()
            timer = nil
            session?.invalidate()
        }
    }
}



#Preview {
    ContentView()
}
