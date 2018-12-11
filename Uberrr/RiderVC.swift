//
//  RiderVC.swift
//  Uberrr
//
//  Created by Ramilia Imankulova on 12/6/18.
//  Copyright © 2018 Ramilia Imankulova. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var callAnUberBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if let email = Auth.auth().currentUser?.email{
            //retrieving info
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.uberHasBeenCalled = true
                self.callAnUberBtn.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            if let email = Auth.auth().currentUser?.email {
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                    if let rideRequestDictionary = snapshot.value as? [String : AnyObject] {
                                        if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayDriverAndRider(){
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: userCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        callAnUberBtn.setTitle("Your driver is \(roundedDistance) km away", for: .normal)
//
//        map.removeAnnotation(map?.annotations)
        let latDelta = abs (driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs (driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your location"
        map.addAnnotation(riderAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Your driver"
        map.addAnnotation(driverAnnotation)
        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
           
            if uberHasBeenCalled {
                displayDriverAndRider()
              
            } else {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                map.setRegion(region, animated: true)
                //            map.removeAnnotation(map?.annotations as! MKAnnotation)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your location"
                map.addAnnotation(annotation)
            }
        }
    }
    
   

    @IBAction func callUberTapped(_ sender: Any) {
        if !driverOnTheWay {
        if let email = Auth.auth().currentUser?.email {
            if uberHasBeenCalled {
                
                uberHasBeenCalled = false
                callAnUberBtn.setTitle("Call an Uber", for: .normal)
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                }
                
            } else {
                let rideRequestDictionary : [String: Any] = ["email" : email, "lat" : userLocation.latitude, "lon" : userLocation.longitude ]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                uberHasBeenCalled = true
                callAnUberBtn.setTitle("Cancel Uber", for: .normal)
            }
            }
        }
    }
    
    
    @IBAction func logOutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    
}
