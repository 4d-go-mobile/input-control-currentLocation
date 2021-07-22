//
//  EmailContactRow.swift
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___
//

import UIKit
import MapKit
import CoreLocation

import Eureka
import QMobileUI

// name of the format
fileprivate let kCurrentLocation = "currentLocation"

// Create an Eureka row for the format
final class CurrentLocationRow: FieldRow<CurrentLocationCell>, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
    }

}

// Create the associated row cell
open class CurrentLocationCell: EmailCell, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        self.isUserInteractionEnabled = false
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestLocation()
        }
    }
    
    open override func update() {
        self.textField.font = .italicSystemFont(ofSize: self.textField.font?.pointSize ?? 12)
    }
 
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate ?? locations.first?.coordinate {
            var value = ""
            if locValue.latitude>0 {
                value="+\(locValue.latitude)"
            } else {
                value="\(locValue.latitude)"
            }
            if locValue.longitude>0 {
                value+="+\(locValue.longitude)"
            } else {
                value+="\(locValue.longitude)"
            }
            self.row.value = value
            self.textField.text = value
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.warning("\(error)")
        self.row.value = ""
        self.textField.text = ""
    }

}

@objc(CurrentLocationRowService)
class CurrentLocationRowService: NSObject, ApplicationService, ActionParameterCustomFormatRowBuilder {
    @objc static var instance: CurrentLocationRowService = CurrentLocationRowService()
    override init() {}
    func buildActionParameterCustomFormatRow(key: String, format: String, onRowEvent eventCallback: @escaping OnRowEventCallback) -> ActionParameterCustomFormatRowType? {
        if format == kCurrentLocation {
            return CurrentLocationRow(key).onRowEvent(eventCallback)
        }
        return nil
    }
}
