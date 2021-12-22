//
//  ContentView.swift
//  IsMuteOn
//
//  Created by Doug Marttila on 12/21/21.
//

import SwiftUI

struct ContentView: View {
    
    func checkMute1 () {
        CheckMute.shared.checkForMute {
            isMuted = CheckMute.shared.muteIsOn
            mutedStr1 = isMuted! ? "Device is muted" : "Device isn't muted"
            print("Call back in Content View 1")
        }
    }
    func checkMute2 () {
        CheckMute.shared.checkForMute {
            isMuted = CheckMute.shared.muteIsOn
            mutedStr2 = isMuted! ? "Device is muted" : "Device isn't muted"
            print("Call back in Content View 2")
        }
    }

    @State private var isMuted: Bool? = nil
    @State private var mutedStr1 = "-"
    @State private var mutedStr2 = "-"

    var body: some View {
        VStack {
            Text("Two checks to make sure the callback comes to both views if they're both clicked")
            Divider()
            HStack {
                Text(mutedStr1)
                Button("Check mute 1") {
                    checkMute1()
                }
            }
            Divider()
            HStack {
                Text(mutedStr2)
                Button("Check mute 2") {
                    checkMute2()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
