//
//  FirebaseLayer.swift
//  TrackingLocation
//
//  Created by Islam NourEldin on 21/07/2022.
//

import Foundation
import Firebase

class FirebaseServices{
    
    static let shared = FirebaseServices()
    private let database = Firestore.firestore()
    typealias postTripCompletionError = (Error?)->Void
    private init(){
        
    }
    
    
    func postTrip(trip:Trip,completion: @escaping postTripCompletionError){
        
        let data = ["startPoint":trip.startPoint,
                    "destinationPoint":trip.destinationPoint,
                    "TripTime":trip.timeStamp]
        
        Firestore.firestore().collection("Trips").addDocument(data: data,completion: completion)
    }
    
    func getTrips(completion: @escaping ([Trip]?)->Void){
        database.collection("Trips").order(by: "TripTime").getDocuments { querySnapshot, error in
            
            var tripsTempArray = [Trip]()
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion([])
            }else{
                
                for document in querySnapshot!.documents{
                    guard let start = document.data()["startPoint"] as? GeoPoint else{return}
                    
                    guard let end = document.data()["destinationPoint"] as? GeoPoint else {return}
                    
                    guard let time = document.data()["TripTime"] as? Timestamp else {return}
                    
                    let trip = Trip(startPoint: start, destinationPoint: end,timeStamp: time)
                    tripsTempArray.append(trip)
                }
                DispatchQueue.main.async {
                    completion(tripsTempArray)
                }
            }
            
        }
    }

}
