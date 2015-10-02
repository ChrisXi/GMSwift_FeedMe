//
//  MapViewController.swift
//  Feed Me
//
/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class MapViewController: UIViewController, TypesTableViewControllerDelegate {
  
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    self.mapView.delegate = self

  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
  
  func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
    
    let geocoder = GMSGeocoder()
    
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      if let address = response?.firstResult() {
        self.addressLabel.unlock()
        
        let lines = address.lines as! [String]
        self.addressLabel.text = lines.joinWithSeparator("\n");  // = join("\n", lines)
        
        UIView.animateWithDuration(0.25) {
          self.view.layoutIfNeeded()
        }
      }
    }
    
    let labelHeight = self.addressLabel.intrinsicContentSize().height
    self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0,
      bottom: labelHeight, right: 0)
    
    UIView.animateWithDuration(0.25) {
      self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
      self.view.layoutIfNeeded()
    }
  }

}

// MARK: - TypesTableViewControllerDelegate
extension MapViewController{//: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
  }
}

extension MapViewController: CLLocationManagerDelegate {

  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedWhenInUse {
      
      locationManager.startUpdatingLocation()
      
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true

    }
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last;
      
    mapView.camera = GMSCameraPosition(target: location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    
    locationManager.stopUpdatingLocation()
    
  }
}

extension MapViewController: GMSMapViewDelegate {
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    reverseGeocodeCoordinate(position.target)
  }
  func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
    addressLabel.lock()
  }
}

