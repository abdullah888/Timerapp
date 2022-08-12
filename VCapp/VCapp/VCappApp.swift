//
//  VCappApp.swift
//  VCapp
//
//  Created by abdullah on 14/01/1444 AH.
//

import SwiftUI

@main
struct VCappApp: App {
    @StateObject var TimeModel: TimeViewModel = .init()
    @Environment(\.scenePhase) var phase
    @State var lastActiveTimeStamp: Date = Date()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TimeModel)
        }
        .onChange(of: phase) { newValue in
            if TimeModel.isStarted{
                if newValue == .background{
                    lastActiveTimeStamp = Date()
                }
                
                if newValue == .active{
                    let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
                    if TimeModel.totalSeconds - Int(currentTimeStampDiff) <= 0{
                        TimeModel.isStarted = false
                        TimeModel.totalSeconds = 0
                        TimeModel.updateTimer()
                    }else{
                        TimeModel.totalSeconds -= Int(currentTimeStampDiff)
                    }
                }
            }
        }
    }
}
