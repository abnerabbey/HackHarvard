//
//  Speech.swift
//  ParseStarterProject
//
//  Created by Tyler Weitzman on 6/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import AVFoundation

protocol SpeechDelegate {
    func wordWillBeSpoken(word: String)
    func didFinish()
    func updateTimeRemaining (time: Double, percentComplete: Double)
    func paused()
    func stopped()
    func playing()
}

class Speech: NSObject {
    var synthesizer = AVSpeechSynthesizer()
    var delegate : SpeechDelegate?
    var utterance : AVSpeechUtterance?
    var totalString : String?
    var estimatedLength : Double = 0
    var refreshRate = false
    var cursor : Int = 0
    var wordRefreshCount = 0
    var startDate : NSDate?
    var letterTimeRate : Double? {
        didSet {
            if let str = totalString {
                if (letterTimeRate != nil) {
                    estimatedLength = letterTimeRate! * (Double)(str.characters.count)
                    if let del = delegate {
                        del.updateTimeRemaining(estimatedLength, percentComplete: 0)
                    }
                }
            }
        }
    }
    var letterTimeRateScale : Double = 1
    var scaledRate : Float = 1.0 {
        didSet {
            //            0 -> 1
            //            0.5 -> 3
            //             scaledRate = (rate + 0.5) * 2
            rate = (Float)((scaledRate-(0.2)-0.5) / 2.5)
            refreshRate = synthesizer.speaking
            letterTimeRate = nil
            //            println("setting rate equal to \(rate)")
            //            println("yo")
        }
    }
    var rate : Float = 0.5 {
        didSet {
            //           let sr = (Float)((rate + 0.5) * 2)
            //           if sr != scaledRate {
            //                scaledRate = sr
            //           }
            utterance?.rate = rate
        }
    }
    override init() {
        super.init()
        synthesizer.delegate = self
        print("\(AVSpeechUtteranceMinimumSpeechRate) \(AVSpeechUtteranceDefaultSpeechRate) \(AVSpeechUtteranceMaximumSpeechRate)")
        
    }
    
    //    func timePerCharacterPerWord
    static func defaultLengthForString(string: String) -> String? {
        let len = (Double)(string.characters.count) * Constants.defaultLetterTime
        //        len = 64.4
        var string = formatTime(len)
        string = string! + " "
        //        if let str = string {}
        return string
        /*
        println(len)
        len = 64.0
        var nsstring = NSString(format:"%2d", len)
        if let str = nsstring as? String {
        return str
        } else {
        return " "
        }*/
        
    }
    
    static func formatTime(time: Double?) -> String? {
        if let t : Double = time {
            let intTime = (Int)(t)
            switch t {
            case 0...60:
                return String(format: "0:%02d", intTime)
            case 60...60*60*60:
                let seconds = intTime % 60
                let minutes = (Int)(intTime / 60)
                return String(format: "%d:%02d", minutes, seconds)
            default:
                return " "
            }
        } else{
            return " "
        }
    }
    func scanToWord(word: String) {
        
        if let totalString = totalString {
            let inRange = Range<String.Index>(start: totalString.startIndex.advancedBy(cursor), end: totalString.endIndex)
            if let range = totalString.rangeOfString(word, options: NSStringCompareOptions.CaseInsensitiveSearch, range:inRange){
                print("\(range.startIndex) hi")
                self.stopSpeaking()
                self.speak(totalString.substringFromIndex(range.startIndex))
            }
        }
    }
    func updateCursor(percent: Double) {
        if let totalString = totalString {
            let totalLen = (Double)(totalString.characters.count)
            print("Percent \(percent) Total \(totalLen)")
            let loc = (Int)(percent * totalLen)
            cursor = loc
        } else {
            cursor = 0
            
        }
        print("Cursor \(cursor)")
    }
    func speak(string: String) {
        delegate?.playing()
        if totalString == nil {
            totalString = string
            cursor = 0
        }
        wordRefreshCount = 0
        if let utterance = utterance {
            synthesizer.continueSpeaking()
            delegate?.playing()
        } else {
            utterance = AVSpeechUtterance(string: string)
            utterance!.rate = rate
            utterance?.volume = 1.0
            //            println(rate)
            synthesizer.speakUtterance(utterance!)
            wordRefreshCount = 0
        }
    }
    
    func pause() {
        synthesizer.pauseSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        delegate?.paused()
        
    }
    func backwards() {
        //15 seconds
        if let totalString = totalString {
            var lr = letterTimeRate
            if lr == nil {
                lr = Constants.defaultLetterTime
            }
            let wordsBack = (Int)(15.0 / (lr!))
            var loc = self.cursor - wordsBack
            if loc < 0 { loc = 0 }
            if totalString.endIndex != totalString.startIndex {
                let stringToSpeak = totalString.substringFromIndex(totalString.startIndex.advancedBy(loc))
                self.stopSpeaking()
                self.speak(stringToSpeak)
            }
        }
        
    }
    func forwards() {
        //15 seconds
        if let totalString = totalString {
            var lr = letterTimeRate
            if lr == nil {
                lr = Constants.defaultLetterTime
            }
            let wordsBack = (Int)(15.0 / (lr!))
            let loc = self.cursor + wordsBack
            if loc > totalString.characters.count {
                self.stopSpeaking()
                
            } else {
                let stringToSpeak = totalString.substringFromIndex(totalString.startIndex.advancedBy(loc))
                self.stopSpeaking()
                self.speak(stringToSpeak)
            }
        }
        
    }
    func continueSpeaking() {
        synthesizer.continueSpeaking()
        delegate?.playing()
    }
    func stopSpeaking() {
        delegate?.stopped()
        synthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        self.utterance = nil
    }
    func restartWithPercent(percent: Double) {
        print("percent \(percent)")
        if let totalString = totalString {
            self.stopSpeaking()
            let totalLen = (Double)(totalString.characters.count)
            let loc = (Int)(percent * totalLen)
            let remaining = totalString.substringFromIndex(totalString.startIndex.advancedBy(loc))
            self.speak(remaining)
        }
        
    }
    func countCharacters(string: String, characters: String) -> Double {
        var i = 0.0
        for x in string.characters {
            for char in characters.characters {
                if x==char {
                    i++
                }
            }
        }
        return i
    }
}

extension Speech : AVSpeechSynthesizerDelegate {
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        wordRefreshCount++
        if wordRefreshCount==2 {
            startDate = NSDate()
            letterTimeRateScale = (Double)(characterRange.length)
        } else if wordRefreshCount==3 {
            letterTimeRate = NSDate().timeIntervalSinceDate(startDate!) / letterTimeRateScale
            letterTimeRate = letterTimeRate! + 0.1
            print("Time Rate: \(letterTimeRate)")
            
        }
        let speechString = utterance.speechString
        
        /* Estimate time */
        
        
        
        let remaining = speechString.substringFromIndex(speechString.startIndex.advancedBy(characterRange.location))
        
        let range = Range(start: speechString.startIndex.advancedBy(characterRange.location), end: speechString.startIndex.advancedBy(characterRange.location + characterRange.length))
        //        println("\(speechString) \(characterRange.location) : \(characterRange.length)")
        let word = speechString.substringWithRange(range)
        if refreshRate {
            print("Refresh rate")
            //            startDate = NSDate()
            //            wordRefreshCount = 0
            
            //            self.utterance = nil
            self.stopSpeaking()
            speak(remaining)
            refreshRate = false
        }
        if let delegate = delegate {
            delegate.wordWillBeSpoken(word)
            if let letterTimeRate = letterTimeRate {
                let lenRemaining = (Double)(remaining.characters.count)
                //                var punchCount = countCharacters(remaining, characters: ",.?!;—-")
                //                println(punchCount)
                //                var timeRemaining = lenRemaining * (Double)(letterTimeRate) + punchCount * 0.35
                let timeRemaining = lenRemaining * (Double)(letterTimeRate)
                let percent = (estimatedLength-timeRemaining) / estimatedLength
                delegate.updateTimeRemaining(timeRemaining, percentComplete: percent)
                updateCursor(percent)
                
            }
            
        }
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance)
    {
        //        println("Stopping")
        self.utterance = nil
        if let delegate = delegate {
            delegate.didFinish()
        }
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didPauseSpeechUtterance utterance: AVSpeechUtterance) {
        delegate?.paused()
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didCancelSpeechUtterance utterance: AVSpeechUtterance) {
        delegate?.paused()
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        delegate?.playing()
    }
    
    
    
}
