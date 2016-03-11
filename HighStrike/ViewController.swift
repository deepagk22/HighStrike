//
//  ViewController.swift
//  HighStrike
//
//  Created by Deepa Krishnan on 11/18/15.
//  Copyright © 2015 Deepa Krishnan. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
class ViewController: UIViewController {

    @IBOutlet weak var ScoreLabel: UILabel!
    let motionManager = CMMotionManager()
    var velocity: Double = 0.0
    var player: AVAudioPlayer = AVAudioPlayer()
    @IBOutlet weak var rollSlider: UISlider!{
        didSet{
            rollSlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
            
        }
    }
    func roundToPlaces(value:Double, places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
      
    override func viewWillAppear(animated: Bool) {
        rollSlider.minimumValue = -1.0
        rollSlider.maximumValue = 1.0
        
        if motionManager.deviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            getAccelrationDataonMotion()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if motionManager.deviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    var cuurentMaxAccelX : Double = 0.0
    var currentMaxAccelY : Double = 0.0
    var cuurentMaxAcceZ : Double = 0.0
    var prevroll: Double = 0.0
    func updateSliderUsingRoll(acceleration: CMAcceleration) {
        let motion = motionManager.deviceMotion
        if motion != nil {
            let roll = velocity
            
            dispatch_async(dispatch_get_main_queue(), {
                var sliderValue = self.rollSlider.value
                
                if ( roll < self.prevroll ) {
                    sliderValue = sliderValue - 0.1;
                } else {
                    sliderValue = sliderValue + 0.1;
                }
                self.prevroll = roll
                self.rollSlider.setValue( sliderValue, animated: true )
            })
            if fabs(acceleration.x) > fabs(cuurentMaxAccelX)
            {
                cuurentMaxAccelX = acceleration.x
            }
            currentMaxAccelY = acceleration.y
            if fabs(acceleration.y) > fabs(currentMaxAccelY)
            {
                
            }
            if fabs(acceleration.z) > fabs(cuurentMaxAcceZ)
            {
                cuurentMaxAcceZ = acceleration.z
            }
            velocity = sqrt( pow(acceleration.x, 2.0) + pow(acceleration.y, 2.0) + pow(acceleration.z, 2.0))
        }
    }
    
    func getAccelrationDataonMotion(){
        
        
        if motionManager.accelerometerAvailable{
            let queue = NSOperationQueue()
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        //self.outputAccelerationData(data.acceleration)
                        self.velocity = abs(data.acceleration.y)
                        
                        self.updateSliderUsingRoll(data.acceleration)
                    })
                }
                
            )
        } else {
            print("Accelerometer is not available")
        }
        
        
    }

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        
        if event!.subtype == UIEventSubtype.MotionShake {
            let fileLocation = NSBundle.mainBundle().pathForResource("Metal", ofType: "mp3")
            var error: NSError? = nil
            
            do {
                player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: fileLocation!))
            } catch let error1 as NSError {
                error = error1
                
            }
            var score: Int = Int(velocity * 100)
            
            if score < 0{
                score = 0
            }
            
            
            self.ScoreLabel.text = String(score)
            if abs(currentMaxAccelY) > 2.5{
                velocity = 1.0
            }
            else
            {
                velocity = abs(currentMaxAccelY)
            }

            
            player.volume = Float(velocity)
            
            player.play()
            
            motionManager.stopDeviceMotionUpdates()
        }
        
        
    }

}

