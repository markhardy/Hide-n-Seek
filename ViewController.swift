//
//  ViewController.swift
//  HideNSeek
//
//  This app is a companion to an iBeacon device that one player can hide and
//  another player can search for.
//
//  Created by Mark Hardy on 3/30/18.
//  Updated on 3/6/19.
//  Copyright © 2018 Mark Hardy. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var current_color = UIColor.red
    
    // Two timers: one for when the button flashes and other for unflashing
    var timer = Timer()
    var unflash_timer = Timer()
    
    @IBOutlet weak var light_img: UIImageView!
    
    let blue_btn = UIImage(named: "blue_btn.png")
    let green_btn = UIImage(named: "green_btn.png")
    let orange_btn = UIImage(named: "orange_btn.png")
    let red_btn = UIImage(named: "red_btn.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Look for beacons
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        start_flash(interval: 2.0)
    }
    
    
    /*
     Asks user for permission to access location while app is running
    */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    /*
     Starts scanning for the Bluetooth Beacon
    */
    func startScanning() {
        let uuid = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 1, minor: 532, identifier: "MyBeacon")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    /*
     This is called when our beacon is detected
    */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            updateDistance(beacons[0].proximity)
        } else {
            updateDistance(.unknown)
        }
    }
    
    /*
     Change the button color to a given parameter
    */
    func setBtnColor(color: UIColor){
        self.current_color = color
    }
    
    /*
     When beacon is detected, this method figures out how far away it is
     and changes the button's color depending on that distance
    */
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.setBtnColor(color: UIColor.red)
            case .far:
                self.setBtnColor(color: UIColor.orange)

            case .near:
                self.setBtnColor(color: UIColor.green)

            case .immediate:
                self.setBtnColor(color: UIColor.blue)
            }
        }
    }
    
    //*************************************************
    //  Begins the sequence to cause the screen's
    //  button to flash depending on how close the
    //  user is to the beacon. Restarts sequence if
    //  one was already running.
    //
    //  ARGUMENT 'interval' is a double that determines
    //  how much time the flashes are spaced by
    //*************************************************
    func start_flash(interval: Double) {
        // Every interval seconds, call the selector
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(ViewController.flash), userInfo: nil, repeats: true)
    }
    
    //*************************************************
    //  Turns the button white effectively making it
    //  appear to flash
    //*************************************************
    func flash(){
        light_img.image = nil
        flashTime()
    }
    
    //*************************************************
    //  After .15 seconds, this method calls the
    //  selector to restore the color to normal
    //*************************************************
    func flashTime(){
        unflash_timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(ViewController.unflash), userInfo: nil, repeats: false)
        
    }
    
    //*************************************************
    //  Sets the color back to what it normally is
    //  effectively ending the flash
    //*************************************************
    func unflash(){
        switch current_color {
        case UIColor.green:
            light_img.image = green_btn
        case UIColor.orange:
            light_img.image = orange_btn
        case UIColor.red:
            light_img.image = red_btn
        case UIColor.blue:
            light_img.image = blue_btn
        default:
            light_img.image = blue_btn
        }
    }
}

