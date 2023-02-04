//
//  ViewController.swift
//  WaterFilter
//
//  Created by Glenn Anderson on 3/18/21.
//

import UIKit
import CoreBluetooth
import OSLog

/* Aquasana AQ-5300+
 Service UUID 0xFEF8: Aplix Corporation
 Manufacturer ID 0x00BD: Aplix Corporation
<bd00000d c40f000d 378601> 27%
<bd00000d c40f000d 388601> 27%
<bd00000d c40f000d 3a8601> 27%
<bd00000d c40f000d 3d8601> 27%
<bd00000d c40f000d 3f8601>
<bd00000d c40f000d 408601> 26%
<bd00000d c40f000d 418701>
<bd00000d c40f000d 458701>
<bd00000d c40f000d 4c8701>
<bd00000d c40f000d 4d8701> 25%
<bd00000d c40f000d 4e8701>
<bd00000d c40f000d 558701>
<bd00000d c40f000d 558701>
<bd00000d c40f000d 578701>
<bd00000d c40f000d 588701>
<bd00000d c40f000d 598701>
<bd00000d c40f000d 688801>
<bd00000d c40f000d 688801> 25%
<bd00000d c40f000d 748801>
<bd00000d c40f000d 768801>
<bd00000d c40f000d 778801>
<bd00000d c40f000d 7a8801>
<bd00000d c40f000d 7b8801>
<bd00000d c40f000d 8c8801>
<bd00000d c40f000d 8f8801>
<bd00000d c40f000d 918801>
<bd00000d c40f000d 928801>
<bd00000d c40f000d 9e8901> 24%
<bd00000d c40f000d a28901>
<bd00000d c40f000d a38901> 24%
<bd00000d c40f000d a78901>
<bd00000d c40f000d a88901>
<bd00000d c40f000d b18a01>
<bd00000d c40f000d b28a01>
<bd00000d c40f000d b88a01>
<bd00000d c40f000d bf8a01>
<bd00000d c40f000d c28a01>
<bd00000d c40f000d ce8b01>
<bd00000d c40f000d d18b01>
<bd00000d c40f000d db8b01>
<bd00000d c40f000d dc8b01> 24%
<bd00000d c40f000d e08c01>
<bd00000d c40f000d e38c01>
<bd00000d c40f000d ec8c01>
<bd00000d c40f000d f08c01>
<bd00000d c40f000d f18d01> 23%
<bd00000d c40f000e 038d01> 22%
<bd00000d c40f000e 0a8d01>
<bd00000d c40f000e 398f01>
<bd00000d c40f000e 468f01> 21%
<bd00000d c40f000e 519001>
<bd00000d c40f000e 549001>
<bd00000d c40f000e 5a9101> 20%
<bd00000d c40f000e 5b9101>
<bd00000d c40f000e 609101> 20%
<bd00000d c40f000e 719101> 20%
<bd00000d c40f000e 759201> 19%
<bd00000d c40f000e 849301> 19%
<bd00000d c40f000e 879301> 19%
<bd00000d c40f000e 8b9301>
<bd00000d c40f000e 979401>
<bd00000d c40f000e a39401> 18%
<bd00000d c40f000e af9501>
<bd00000d c40f000f 199801> 16%
<bd00000d c40f000f 259801>
<bd00000d c40f000f 529a01> 15%
<bd00000d c40f000f 5b9a01> 15%
<bd00000d c40f000f 779c01> 14%
<bd00000d c40f000f 8d9d01> 13%
<bd00000d c40f000f c39e01>
<bd00000d c40f000f ca9e01> 13%
<bd00000d c40f000f d39e01>
<bd00000d c40f000f d59e01>
<bd00000d c40f000f d69e01>
<bd00000d c40f000f dd9e01>
<bd00000d c40f000f e09e01>
<bd00000d c40f000f e19e01>
<bd00000d c40f000f e89f01>
<bd00000d c40f000f e99f01>
<bd00000d c40f000f ea9f01> 12%
<bd00000d c40f000f ec9f01> 12%
<bd00000d c40f000f ed9f01> 12%
<bd00000d c40f000f f09f01>
<bd00000d c40f000f f39f01>
<bd00000d c40f000f f49f01>
<bd00000d c40f000f fe9f01> Clear ice fill?
<bd00000d c40f000f ff9f01> 12%
<bd00000d c40f0010 009f01> 12%
<bd00000d c40f0010 01a001>
<bd00000d c40f0010 01a001>
<bd00000d c40f0010 03a001>
<bd00000d c40f0010 06a001>
<bd00000d c40f0010 07a001>
<bd00000d c40f0010 09a001>
<bd00000d c40f0010 0ca001>
<bd00000d c40f0010 0da001>
<bd00000d c40f0010 10a001>
<bd00000d c40f0010 12a001>
<bd00000d c40f0010 17a001>
<bd00000d c40f0010 18a001>
<bd00000d c40f0010 1aa001>
<bd00000d c40f0010 1ba001>
<bd00000d c40f0010 23a001>
<bd00000d c40f0010 28a101> 11%
<bd00000d c40f0010 2ba101>
<bd00000d c40f0010 2da101>
<bd00000d c40f0010 31a101>
<bd00000d c40f0010 34a101>
<bd00000d c40f0010 36a101>
<bd00000d c40f0010 52a201>
<bd00000d c40f0010 71a301> 10%
<bd00000d c40f0010 8ca401>
<bd00000d c40f0010 93a501> 9%
<bd00000d c40f0010 96a501>
<bd00000d c40f0010 97a501>
<bd00000d c40f0010 a0a501> 1l
<bd00000d c40f0010 a8a501> 1l
<bd00000d c40f0010 b1a501> 1l
<bd00000d c40f0010 b9a501> 1l
<bd00000d c40f0010 bba501>
<bd00000d c40f0010 c6a601> 8%
<bd00000d c40f0010 eca601>
<bd00000d c40f0010 fca701>
<bd00000d c40f0011 0ca801> 7%
<bd00000d c40f0011 21a901> 7%
<bd00000d c40f0011 49aa01>
<bd00000d c40f0111 4dab01>
<bd00000d c40f0111 50ab01> 5% beeping
<bd00000d c40f0111 62ac01> 5% beeping
<bd00000d c40f0111 70ad01> 4% beeping
<bd00000d c40f0111 93ae01> 4% beeping
<bd00000d c40f0111 abaf01> 3% beeping
<bd00000d c40f0111 c1b001> 3% beeping
<bd00000d c40f0111 e0b101> 2% beeping
<bd00000d c40f0111 f3b201> 2% beeping
<bd00000d c40f0111 ffb301> 1% beeping
<bd00000d c40f0112 0cb401> 1% beeping
<bd00000d c40f0112 2cb501> "Filter Life Expired" beeping
<bd00000d c40f0112 57b701>
<bd00000d c40f0112 41b601>
<bd00000d c40f0112 aeb901>
<bd00000d c40f0112 bfba01>
<bd00000d c40f0112 d8bb01>
<bd00000d c40f0112 eebc01>
<bd00000d c40f0112 fbbd01>
<bd00000d c40f0113 1abe01>
<bd00000d c40f0113 48c701>
<bd00000d c40f0113 81c901>
<bd00000d c40f0113 83ca01>
<bd00000d c40f0113 a5cb01>
<bd00000d c40f0113 bccc01>
<bd00000d c40f0114 02cf01>
<bd00000d c40f0114 32d101>
<bd00000d c40f0114 49d201>
<bd00000d c40f0115 7be001>
<bd00000d c40f0117 85f401>
<bd00000d c40f0117 f1f801>
<bd00000d c40f0118 36fa01>
<bd00000d c40f0118 5dfc01>
<bd00000d c40f0118 8efe01>
<bd00000d c40f0118 95ff01>
<bd00000d c40f0118 a9ff01>
<bd00000d c40f0119 0dff01>

<bd00000d c40f0000 030001>
<bd00000d c40f0000 6a0001>
<bd00000d c40f0002 030001> ~37l
<bd00000d c40f0002 060001> glass of water with ice
<bd00000d c40f0002 680201>
M/M  ^^^^ ^^^^
beeping flag  ^^
Water volume    ^^ ^^
Days                 ^^
Unknown                ^^

Advertising Address: c1:1c:4d:4f:45:a5 (c1:1c:4d:4f:45:a5)
Manufacturer Specific: Apple (length 26, type 0xFF, 0x004C
Data: 0215 0000000070621001b000001c4d8aa76c 0064 0001 b6

Advertising Address: c2:1c:4d:4f:45:a5 (c2:1c:4d:4f:45:a5)
Data: 0215 249bf7f4546c1801ba01001c4d4d98a6 000d c40f b6
                                            ^^^^ ^^^^
  major and minor match start of Aplix vendor data
*/

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
		if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.starts(with: Self.manufacturerID) {
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
			print("Type: \(location.type())")
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
