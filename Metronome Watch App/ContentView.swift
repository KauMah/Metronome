//
//  ContentView.swift
//  Metronome Watch App
//
//  Created by Kaushik Mahadevan on 7/13/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var metronomeManager = MetronomeManager()
    
    var body: some View {
        VStack {
            Text("BPM: \(Int(floor(metronomeManager.bpm)))")
            Button(action: {
                metronomeManager.toggleMetronome()
            }) {
                Text(metronomeManager.isRunning ? "Stop" : "Start").frame(width: 100)
            }.buttonStyle(.borderedProminent)
        }.focusable(true)
            .digitalCrownRotation(
                $metronomeManager.bpm,
                from: 20,
                through: 200,
                by: 1,
                sensitivity: .medium,
                isHapticFeedbackEnabled: true
            ).onChange(of: metronomeManager.bpm) {
                metronomeManager.stopMetronome()
            }
        .padding()
    }
    
    
}



#Preview {
    ContentView()
}
