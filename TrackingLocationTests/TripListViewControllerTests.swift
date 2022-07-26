//
//  TripListViewControllerTests.swift
//  TrackingLocationTests
//
//  Created by Islam NourEldin on 26/07/2022.
//

import XCTest
@testable import TrackingLocation

class TripListViewControllerTests: XCTestCase {

    var storyboard: UIStoryboard!
    var sut : TripsListViewController!
    
    override func setUpWithError() throws {
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "TripsListViewController") as? TripsListViewController
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        
        storyboard = nil
        sut = nil
        
    }

    func test_ViewController_WhenCreated_HasRecordBtnAndAction() throws{
        //Arrange
        let recordButton: UIButton = try XCTUnwrap(sut.recordBtn, "Record button doesn't have a referencing outlet")
        
        //Act
        let recordActions = try XCTUnwrap ( recordButton.actions(forTarget: sut, forControlEvent: .touchUpInside),"Record button doesn't have any actions assigned to it")
        //Assert
        XCTAssertEqual(recordActions.count, 1)
        
        XCTAssertEqual(recordActions.first,"recordBtnTapped","There is no action with a name recordBtn assigned to record button")
        
    }

}
