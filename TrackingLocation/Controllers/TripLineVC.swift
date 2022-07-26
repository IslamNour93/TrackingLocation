//
//  TripLineVC.swift
//  TrackingLocation
//
//  Created by Islam NourEldin on 19/07/2022.
//

import UIKit
import MapKit
import CoreLocation

class TripLineVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    
    var trip: Trip?
    
    private let locationManager = CLLocationManager()
    
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
       setupLocationManager()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    // MARK: Private Functions
    
    private func setupLocationManager(){
        
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
        locationManager.stopUpdatingLocation()
        if CLLocationManager.locationServicesEnabled(){
            checkAuthentication()
           
            zoomToUserLocation(location:CLLocation(latitude: trip?.startPoint.latitude ?? 0, longitude: trip?.startPoint.longitude ?? 0))
            
            drawTripLine(startingPoint: CLLocationCoordinate2D(latitude: trip?.startPoint.latitude ?? 0, longitude: trip?.startPoint.longitude ?? 0), destinationPoint: CLLocationCoordinate2D(latitude: trip?.destinationPoint.latitude ?? 0, longitude: trip?.destinationPoint.longitude ?? 0))
            
        }
    }
    
    private func checkAuthentication(){
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            break
        case .authorizedAlways:
            break
        case .denied:
            
            CLLocationManager.locationServicesEnabled()
            break
        case .restricted:
            break
        default:
            break
        }
    }
    
    private func zoomToUserLocation(location:CLLocation){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(region, animated: true)
    }
    
    private func drawTripLine(startingPoint:CLLocationCoordinate2D,destinationPoint:CLLocationCoordinate2D){
        
        let startingPlace = MKPlacemark(coordinate: startingPoint)
        let destinationPlace = MKPlacemark(coordinate: destinationPoint)
        
        let startingItem = MKMapItem(placemark: startingPlace)
        let destinationItem = MKMapItem(placemark: destinationPlace)
        
        let request = MKDirections.Request()
        request.source = startingItem
        request.destination = destinationItem
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error{
                    print("Directions error is \(error.localizedDescription)")
                }
                return
            }
            for route in response.routes{
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .red
        return render
    }
}
