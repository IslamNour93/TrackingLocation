//
//  TrackingLocationTests.swift
//  TrackingLocationTests
//
//  Created by Islam NourEldin on 17/07/2022.
//

import XCTest
import Firebase
@testable import TrackingLocation

class FirebaseNetworkTests: XCTestCase {

    private var sut: FirebaseServices!
    
    override func setUpWithError() throws {
        sut = FirebaseServices.shared
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    
    func test_PostTrip_WhenNotGivenError_ThenPostSuccessfully(){
        
        let testTrip = Trip(startPoint: GeoPoint(latitude: 37.685834, longitude: -122.306417) , destinationPoint: GeoPoint(latitude: 37.785834, longitude: -122.406417), timeStamp: Timestamp(date: .now))
        let exp = expectation(description: "Waiting for posting the trip")
        var postResponseError:Error?
        
        
        sut.postTrip(trip: testTrip) { error in
            if error != nil{
            postResponseError = error
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNil(postResponseError)
    }
    
    
    func test_WhenTripIsNotNilAndGetTripsIsCalled_ThenTheTripIsAdded(){
        
        
        // Given
        let exp = expectation(description: "Waiting for async operation")
        
        var testTrips = [Trip]()
        
        //When
        sut.getTrips { trips in
            guard let trips = trips else {
                return
            }
            testTrips = trips
            
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        //Then
        XCTAssertNotNil(testTrips)
    }

}
