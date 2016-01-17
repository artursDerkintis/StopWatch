//
//  InterfaceController.swift
//  StopWatch WatchKit Extension
//
//  Created by Arturs Derkintis on 1/17/16.
//  Copyright © 2016 Starfly. All rights reserved.
//

import WatchKit
import Foundation



class InterfaceController: WKInterfaceController {
    
    @IBOutlet var splitTimeLabel: WKInterfaceLabel!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var lapButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var stopButton: WKInterfaceButton!
    
    
    var startTime = NSTimeInterval()
    var currentTime = NSTimeInterval()
    
    var lapTime = NSTimeInterval()
    var currentLapTime = NSTimeInterval()
    var laps = [String]()
    
    var timer = NSTimer()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func lap() {
        addLapTimeToTable()
        updateTable()
    }
    
    
    @IBAction func stopTimer() {
        timer.invalidate()
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let elapsedTime = currentTime - startTime + self.currentTime
        self.currentTime = elapsedTime
        
        let elapsedLapTime = currentTime - lapTime + self.currentLapTime
        self.currentLapTime = elapsedLapTime
        
        startButton.setHidden(false)
        stopButton.setHidden(true)
        resetButton.setHidden(false)
        lapButton.setHidden(true)
    }
    
    @IBAction func reset() {
        
        self.splitTimeLabel.setText("00:00,00")
        self.timerLabel.setText("00:00,00")
        self.currentTime = 0.0
        self.currentLapTime = 0.0
        self.laps.removeAll()
        updateTable()
    }
    
    @IBAction func startTimer() {
        if !timer.valid{
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "updateTime", userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
            lapTime = NSDate.timeIntervalSinceReferenceDate()
            startButton.setHidden(true)
            stopButton.setHidden(false)
            resetButton.setHidden(true)
            lapButton.setHidden(false)
        }
    }
    
    
    func updateTime() {
        totalTime()
        splitTime()
    }
    
    
    func totalTime(){
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        let elapsedTime = currentTime - startTime + self.currentTime
        
        let result = parseElapsedTime(elapsedTime)
        
        let font = UIFont.monospacedDigitSystemFontOfSize(25, weight: UIFontWeightRegular)
        let attributedString = NSAttributedString(string: "\(result.minutes):\(result.seconds),\(result.fraction)", attributes: [NSFontAttributeName : font])
        timerLabel.setAttributedText(attributedString)
    }
    
    func splitTime(){
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let elapsedTime = currentTime - lapTime + self.currentLapTime
        
        let result = parseElapsedTime(elapsedTime)
        
        let font = UIFont.monospacedDigitSystemFontOfSize(10, weight: UIFontWeightRegular)
        let attributedString = NSAttributedString(string: "+ \(result.minutes):\(result.seconds),\(result.fraction)", attributes: [NSFontAttributeName : font])
        
        splitTimeLabel.setAttributedText(attributedString)
    }
    
    
    //MARK: Table Handler
    func addLapTimeToTable(){
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let elapsedTime = currentTime - self.lapTime + self.currentLapTime
        self.lapTime = currentTime
        self.currentLapTime = 0.0
        let result = parseElapsedTime(elapsedTime)
        let lapTimeString = "+ \(result.minutes):\(result.seconds),\(result.fraction)"
        laps.append(lapTimeString)
    }
    
    func updateTable(){
        table.setNumberOfRows(laps.count, withRowType: "row")
        let reversedLaps = laps.reverse()
        for (index, lapTimeString) in reversedLaps.enumerate(){
            let row = table.rowControllerAtIndex(index) as! TimeRow
            row.countLabel.setText("\(reversedLaps.count - index)")
            row.lapTimeLabel.setText(lapTimeString)
        }
        
    }
    
    
    
    
    func parseElapsedTime(elapsedTime : NSTimeInterval) -> (minutes : String, seconds : String, fraction : String){
        var elapsedTime = elapsedTime
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= NSTimeInterval(seconds)
        let fraction = UInt8(elapsedTime * 100)
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        let strFraction = String(format: "%02d", fraction)
        return (strMinutes, strSeconds, strFraction)
    }
    
    
    
}
