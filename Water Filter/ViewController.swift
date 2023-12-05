//
//  ViewController.swift
//  WaterFilter
//
//  Created by Glenn Anderson on 3/18/2021.
//  © Copyright 2021-2023 Glenn Anderson
//

import UIKit
import CoreBluetooth
import CoreLocation
import OSLog

struct WaterFilter: Comparable {
	static func < (lhs: WaterFilter, rhs: WaterFilter) -> Bool {
		let nameComparisonResult = lhs.name.compare(rhs.name)
		if nameComparisonResult == .orderedSame {
			if lhs.volume == rhs.volume {
				return lhs.days < rhs.days
			} else {
				return lhs.volume < rhs.volume
			}
		} else {
			return nameComparisonResult == .orderedAscending
		}
	}
	
	var name: String
	var volume: UInt32
	var days: UInt8
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CLLocationManagerDelegate {
	static let serviceUUID = CBUUID(data: Data([0xFE, 0xF8])) //Aplix Corporation
	static let manufacturerID: [UInt8] = [0xbd, 0x00] //Aplix Corporation
	static let beaconUUID1Bytes: uuid_t = (0x00, 0x00, 0x00, 0x00, 0x70, 0x62, 0x10, 0x01, 0xb0, 0x00, 0x00, 0x1c, 0x4d, 0x8a, 0xa7, 0x6c)
	static let beaconUUID2Bytes: uuid_t = (0x24, 0x9b, 0xf7, 0xf4, 0x54, 0x6c, 0x18, 0x01, 0xba, 0x01, 0x00, 0x1c, 0x4d, 0x4d, 0x98, 0xa6)
	static let beaconUUID1 = UUID(uuid: beaconUUID1Bytes)
	static let beaconUUID2 = UUID(uuid: beaconUUID2Bytes)

	@IBOutlet weak var tableView: UITableView!

	//let bluetoothCache = CoreBluetoothCache()
	var central: CBCentralManager!
	var peripherals: [UUID:WaterFilter] = [:]
	var displayOrder: [UUID] = []

	var locationManager: CLLocationManager!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		central = CBCentralManager()
		central.delegate = self

		locationManager = CLLocationManager()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManager.activityType = .other
	}

	internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
		case .poweredOn:
			print("CBCentral state poweredOn")
//			central.scanForPeripherals(withServices: nil, options: nil)
			central.scanForPeripherals(withServices: [Self.serviceUUID], options: nil)
		case .unknown:
			print("CBCentral state unknown")
		case .resetting:
			print("CBCentral state resetting")
		case .unsupported:
			print("CBCentral state unsupported")
		case .unauthorized:
			print("CBCentral state unauthorized")
		case .poweredOff:
			print("CBCentral state poweredOff")
		@unknown default:
			print("CBCentral state unknown")
		}
	}

	internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		os_log("Discovered %{public}@ %{public}@", String(describing: peripheral.name), String(describing: peripheral.identifier))
		let identifier = peripheral.identifier
		guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.starts(with: Self.manufacturerID) else {
			return
		}
		os_log("ManufacturerData: %{public}@", manufacturerData as NSData)
		let name = peripheral.name ?? identifier.uuidString
		let volume = (UInt32(manufacturerData[7]) << 8) | UInt32(manufacturerData[8])
		let days = manufacturerData[9]
		let displayData = WaterFilter(name: name, volume: volume, days: days)
		if let currentData = peripherals[identifier] {
			if displayData != currentData {
				let indexPath = IndexPath(row: displayOrder.firstIndex(of: identifier)!, section: 0)
				peripherals[identifier] = displayData
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
		} else {
			print("New \(peripheral) \(advertisementData) \(RSSI)")
			peripherals[identifier] = displayData
			let indexPath = IndexPath(row: displayOrder.count, section: 0)
			displayOrder.append(identifier)
			tableView.insertRows(at: [indexPath], with: .automatic)
		}
//		central.stopScan()
	}

	internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return displayOrder.count
	}
	
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BlueToothPeripheral")!
		let peripheral = peripherals[displayOrder[indexPath.row]]!
		let nameView = cell.textLabel!
		nameView.text = peripheral.name
		let detailView = cell.detailTextLabel!
		detailView.text = "vol: \(peripheral.volume) days: \(peripheral.days)"
		return cell
	}
	
	internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		var authorizationStatus: CLAuthorizationStatus
		if #available(iOS 14.0, *) {
			authorizationStatus = manager.authorizationStatus
			print("Location auth: \(authorizationStatus.rawValue) accuracy: \(manager.accuracyAuthorization.rawValue)")
		} else {
			authorizationStatus = CLLocationManager.authorizationStatus()
			print("Location auth: \(authorizationStatus.rawValue)")
		}
		if authorizationStatus == .notDetermined {
			manager.requestAlwaysAuthorization()
		} else if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
//			manager.startUpdatingLocation()
			if #available(iOS 13.0, *) {
				let beaconRegion1 = CLBeaconRegion(uuid: Self.beaconUUID1, identifier: "Beacon 1")
				manager.startMonitoring(for: beaconRegion1)
	//				manager.startRangingBeacons(in: beaconRegion1)
				manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: Self.beaconUUID1))
				let beaconRegion2 = CLBeaconRegion(uuid: Self.beaconUUID2, identifier: "Beacon 2")
				manager.startMonitoring(for: beaconRegion2)
				manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: Self.beaconUUID2))
			} else {
				// Fallback on earlier versions
			}
		}
	}
	
	internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location failed: \(error)")
	}
	
	internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let location = locations.last {
			print("Location: \(location)")
		}
	}
	
	internal func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		print("Enter region: \(region)")
	}
	
	internal func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
		print("Exit region: \(region)")
	}
	
	internal func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
		print("Monitoring failed: \(String(describing: region)) \(error)")
	}
	
	@available(iOS 13.0, *)
	internal func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
		if beacons.count > 0 {
			print("Ranged beacons: \(beacons)")
		}
	}
	
	@available(iOS 13.0, *)
	internal func locationManager(_ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint, error: Error) {
		print("Failed ranging for: \(beaconConstraint) error: \(error)")
	}
}
