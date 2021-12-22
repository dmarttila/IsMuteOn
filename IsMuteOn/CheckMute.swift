//
//  CheckMute.swift
//  IsMuteOn
//
//  Created by Doug Marttila on 12/22/21.
//  System sound creation and playing from: https://www.rockhoppertech.com/blog/apple-system-sounds/
//  Mute check idea from: https://github.com/akramhussein/Mute

//  Play a 1/10th second of silence and time how long it takes. If it takes less than 1/10th second, mute is on. (If the mute button is on when a system sound is triggered iOS doesn't play anything.) This only works for system sounds. AVAudioPlayer will play a sound silently if mute is on.
//  How this can fail:
//  The user could change the mute setting while the silent sound is playing (It's easier to observe this failure if you use the bell sound rather than the oneTenthSecond sound)
//  Maybe if there's a lot going on in the app the timing check might not work. 
//  Will Apple approve this? Don't know
//  Doesn't seem to be an easy way to simulate mute in the simulator, so you need to use a device

import AVFoundation

class CheckMute {
    //singleton which actually feels like the best solution in this case
    public static let shared = CheckMute()
    private init () {}
    //optional in case the value is requested before the test completes
    public var muteIsOn: Bool?
    
    private var timeStamp = 0.0
    private var silence: SystemSoundID = .zero
    private var isPlayingSound = false
    
    //callBack tells the caller that there is a result for the "is the mute button on" test
    //You could just have a single callback, but there could be multiple calls to this test from different views. If so, you'd want all the views to get the result, but there's no need to continually trigger the sound to play if the multiple calls happen before the sound stops playing
    private var callBacks = [() -> Void] ()
    
    public func checkForMute (callBack: @escaping () -> ()) {
        callBacks.append(callBack)
        if isPlayingSound { return }
        isPlayingSound = true
        //create the sound id if it doesn't already exist
        if silence == .zero {
            silence = createSysSound(fileName: "oneTenthSecond", fileExt: "mp3")
        }
        timeStamp = Date().timeIntervalSinceReferenceDate
        AudioServicesPlaySystemSoundWithCompletion(silence) { [weak self] in
            self?.soundFinishedPlaying()
        }
    }
    
    private func createSysSound(fileName: String, fileExt: String) -> SystemSoundID {
        var mySysSound: SystemSoundID = .zero
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExt) else {
            return .zero
        }
        let osstatus = AudioServicesCreateSystemSoundID(url as CFURL, &mySysSound)
        if osstatus != noErr { // or kAudioServicesNoError. same thing.
            print("could not create system sound")
            print("osstatus: \(osstatus)")
        }
        return mySysSound
    }
    
    private func soundFinishedPlaying() {
        isPlayingSound = false
        let timeElapsed = Date().timeIntervalSinceReferenceDate - timeStamp
        print(callBacks.count)
        print("done playing sound \(timeElapsed)")
        muteIsOn = timeElapsed < 0.05
        while callBacks.count > 0 {
            let cb = callBacks.removeFirst()
            cb()
        }
    }
}
