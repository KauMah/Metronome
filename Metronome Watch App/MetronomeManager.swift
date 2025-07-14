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
    @Published var shouldFlash: Bool = false
    
    private var session: WKExtendedRuntimeSession?
    private var beatTimer: DispatchSourceTimer?
    
    
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
        if beatTimer != nil {
            beatTimer?.cancel()
            beatTimer = nil
        }
        if session != nil {
            session?.invalidate()
            session = nil
        }
        startMetronome()
    }
    
    func stopMetronome() {
        if session == nil || beatTimer == nil {return}
        if let timer = beatTimer {
                timer.setEventHandler {} // remove handler
                timer.cancel()
                beatTimer = nil
            }
        session?.invalidate()
        isRunning = false
    }

}

extension MetronomeManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?, ) {
        extendedRuntimeSession.invalidate()
        if let timer = beatTimer {
                timer.cancel()
                beatTimer = nil
            }
        
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        let interval = 60.0 / floor(bpm)
        let queue = DispatchQueue(label: "com.metronome.timer")
        
        beatTimer = DispatchSource.makeTimerSource(queue: queue)
        beatTimer?.schedule(deadline: .now(), repeating: interval, leeway: .microseconds(1))
        beatTimer?.setEventHandler { [weak self] in
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                WKInterfaceDevice.current().play(.start)
                    self.shouldFlash = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.shouldFlash = false
                    }
                }
        }
        beatTimer?.resume()
//        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
//            WKInterfaceDevice.current().play(.directionUp)
//            DispatchQueue.main.async {
//                    self.shouldFlash = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.shouldFlash = false
//                    }
//                }
//        }
        
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        extendedRuntimeSession.invalidate()
//        timer?.invalidate()
//        timer = nil
        if let timer = beatTimer {
                timer.setEventHandler {} // remove handler
                timer.cancel()
                beatTimer = nil
            }
    }
}
