//
//  TripsListViewController.swift
//  TrackingLocation
//
//  Created by Islam NourEldin on 17/07/2022.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class TripsListViewController: UIViewController {

    // MARK: IBOutlets
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var tripsListTableView: UITableView!
    
    // MARK: Properties
    
    private var trips = [Trip]()
    private var startPoint : GeoPoint?
    private var endPoint : GeoPoint?
    private var savedLocations = [CLLocation]()
    private var locationManager = CLLocationManager()
    private var tripLineVC: TripLineVC!
    private var recordBtnIsPressesd = true
    private var timer: Timer?
    private var stopSecondsCounter = 0
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tripsListTableView.delegate = self
        tripsListTableView.dataSource = self
        self.navigationController?.navigationBar.isHidden = true
        setupLocationManager()
        getTrips()
    }
    
    
    // MARK: IBActions
    
    @IBAction func recordBtnTapped(_ sender: Any) {
        
        if recordBtnIsPressesd{
            locationManager.startUpdatingLocation()
            setupLocationManager()
            startRecordingTrip()
           
        }else{
            saveTrip()
        }
    }
    
    
    // MARK: Private Functions
    
    private func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        if isLocationServicesEnabled(){
            checkAuthorization()
            locationManager.startUpdatingLocation()
        }else{
                showAlert(message: "Please enable Location Services")
            }
    }
    
    private func startRecordingTrip(){
        guard let startLocation = savedLocations.last else{return}
        startPoint = GeoPoint(latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        recordBtnIsPressesd = false
        recordBtn.setTitle("Stop Recording", for: .normal)
    }
    
    private func saveTrip(){
        guard let timer = timer else {
            return
        }
        timer.invalidate()
        stopSecondsCounter = 0
        locationManager.stopUpdatingLocation()
        guard let destination = savedLocations.last , let startPoint = startPoint else{return}
        endPoint = GeoPoint(latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude)
        guard let endPoint = endPoint else {return}
        let trip = Trip(startPoint: startPoint, destinationPoint: endPoint, timeStamp:Timestamp(date: .now))
        self.savedLocations.removeAll()
        self.locationManager.startUpdatingLocation()
        FirebaseServices.shared.postTrip(trip: trip) { error in
            if error != nil{
                print("Error in Posting the Trip: \(String(describing: error?.localizedDescription))")
            }
        }
        print("StartPoint \(trip.startPoint), Destination \(trip.destinationPoint)")
        getTrips()
        recordBtnIsPressesd = true
        recordBtn.setTitle("Start Recording", for: .normal)
    }
        
    private func getTrips(){
        FirebaseServices.shared.getTrips { trips in
            if let trips = trips {
                self.trips = trips
                print(self.trips.count)
            }
            self.reloadTableData()
        }
    }
    
    func reloadTableData() {
            print("Refreshing data...")
            DispatchQueue.main.async {
                self.tripsListTableView.reloadData()
                print("Refresh complete!")
            }
        }
    
    // MARK: Objc Functions
    
    @objc func startTimer(){
        
        if locationManager.location?.speed == 0{
            stopSecondsCounter += 60
            if stopSecondsCounter == 300{
                saveTrip()
            }
        }
    }

}

// MARK: TableView DataSource and Delegate

extension TripsListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath)
        DispatchQueue.main.async {
            cell.textLabel?.text = "Trip \(indexPath.row+1)"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tripLineVC = self.storyboard?.instantiateViewController(withIdentifier: "tripLineVC") as? TripLineVC
        tripLineVC.trip = trips[indexPath.row]
        self.navigationController?.pushViewController(tripLineVC, animated: false)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

// MARK: LocationManager Delegate

extension TripsListViewController:CLLocationManagerDelegate{
    
    func isLocationServicesEnabled()->Bool{
        return CLLocationManager.locationServicesEnabled()
    }
    
    private func checkAuthorization(){
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            showAlert(message: "Please authorize the location permission")
            CLLocationManager.locationServicesEnabled()
            break
        case .restricted:
            break
        default:
            break
        }
    }
    
    func showAlert(message: String){
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Close", style: .default))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        present(alert, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let destination = locations.last else{return}
        print("Location:\(destination.coordinate)")
            savedLocations.append(destination)

            
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{

        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            showAlert(message: "Please authorize the location permission")
           
            break
        default:
            break
        }
    }
    
    
}
