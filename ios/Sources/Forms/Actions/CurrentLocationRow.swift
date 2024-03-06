//
//  CurrentLocationRow.swift
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
private let kCurrentLocation = "currentLocation"

// Create an Eureka row for the format
final class CurrentLocationRow: FieldRow<CurrentLocationCell>, RowType {

    required public init(tag: String?) {
        super.init(tag: tag)
    }

}

// Create the associated row cell
open class CurrentLocationCell: _FieldCell<String>, CellType, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        if let value = self.row.value, !value.isEmpty {
            self.textField.text = value
        }
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if self.row.value?.isEmpty ?? true {
            if CLLocationManager.locationServicesEnabled() { // XXX dispatch in queue
                self.locationManager.requestLocation()
            }
        }
        self.textField.gestureRecognizers?.forEach { self.textField.removeGestureRecognizer($0) }
        let textViewRecognizer = UITapGestureRecognizer()
        textViewRecognizer.addTarget(self, action: #selector(touched))
        self.textField.addGestureRecognizer(textViewRecognizer)
        self.textField.delegate = self
    }

    override open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }

    open override func cellCanBecomeFirstResponder() -> Bool {
        return false
    }

    open override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }

    @objc public func touched(textField: UITextField) {
        self.locationManager.requestLocation()
    }

    open override func update() {
        self.textField.font = .italicSystemFont(ofSize: self.textField.font?.pointSize ?? 12)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue: CLLocationCoordinate2D = manager.location?.coordinate ?? locations.first?.coordinate {
            var value = ""
            value+="\(locValue.latitude)".replacingOccurrences(of: ",", with: ".") // other way force local?
            value+=", "
            value+="\(locValue.longitude)".replacingOccurrences(of: ",", with: ".")
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
