//
//  CountdownTimerView.swift
//  
//
//  Created by Jordan Gustafson on 6/17/20.
//

import SwiftUI

public struct CountdownTimerView: View {
    
    let currentTime: TimeInterval
    let totalTime: TimeInterval
    let ringColor: Color
    let ringBackgroundColor: Color?
    
    public var body: some View {
        ZStack {
            ProgressRing(value: currentTime / totalTime,
                         backgroundColor: ringBackgroundColor,
                         foregroundColor: ringColor,
                         lineWidth: 10)
            
            Text(timeString(time: currentTime))
                .font(Font.largeTitle.monospacedDigit())
                .padding()
        }
        .accessibility(value: Text(timeString(time: currentTime)))
        .frame(minWidth: 128, idealWidth: 128)
        
    }
    
    public init(currentTime: TimeInterval, totalTime: TimeInterval, ringColor: Color, ringBackgroundColor: Color? = nil) {
        self.currentTime = currentTime
        self.totalTime = totalTime
        self.ringBackgroundColor = ringBackgroundColor
        self.ringColor = ringColor
    }
    
    private func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format:"%02i:%02i", minutes, seconds)
        } else {
            return String(format:"%02i", seconds)
        }
    }
    
}

struct CountdownTimerView_Previews: PreviewProvider {
    
    @State static var currentTime: Double = 120.0
    
    static var previews: some View {
        VStack {
            CountdownTimerView(currentTime: currentTime,
                               totalTime: 180,
                               ringColor: .orange)
                .padding()
            Slider(value: Self.$currentTime, in: 0...180)
        }
        
    }
    
}

