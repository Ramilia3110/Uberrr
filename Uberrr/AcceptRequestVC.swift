//
//  AcceptRequestVC.swift
//  Uberrr
//
//  Created by Ramilia Imankulova on 12/6/18.
//  Copyright © 2018 Ramilia Imankulova. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestVC: UIViewController {

    @IBOutlet weak var map: MKMapView!
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
    }
    

    @IBAction func acceptTapped(_ sender: Any) {
        // Update for ride request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat" : self.driverLocation.latitude, "driverLon" : self.driverLocation.longitude ])
             Database.database().reference().child("RideRequests").removeAllObservers()
        }
        // Give directions
        let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count  > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    

}
