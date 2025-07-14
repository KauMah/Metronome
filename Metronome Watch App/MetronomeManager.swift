//
//  MetronomeManager.swift
//  Metronome
//
//  Created by Kaushik Mahadevan on 7/13/25.
//
import SwiftUI
import Foundation

class MetronomeManager: NSObject, ObservableObject  {
    @Published var isRunning: Bool = false
    @Published var bpm: Double = 80
    
    private var timer: Timer?
    private var session: WKExtendedRuntimeSession?
    
    func toggleMetronome() {
        isRunning.toggle()
        isRunning ? startMetronome() : stopMetronome()
    }
    
    func startMetronome() {
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
    }
    
    func restartMetronome() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        if session != nil {
            session?.invalidate()
            session = nil
        }
        startMetronome()
    }
    
    func stopMetronome() {
        if session == nil || timer == nil {return}
        timer?.invalidate()
        session?.invalidate()
        isRunning = false
    }

}

extension MetronomeManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?, ) {
        extendedRuntimeSession.invalidate()
        timer?.invalidate()
        timer = nil
        
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        let interval = 60.0 / floor(bpm)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            WKInterfaceDevice.current().play(.start)
        }
        
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        extendedRuntimeSession.invalidate()
        timer?.invalidate()
        timer = nil
    }
}
