//
//  ViewController.swift
//  WaterFilter
//
//  Created by Glenn on 3/18/21.
//

import UIKit
import CoreBluetooth

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

Advertising Address: c1:1c:4d:4f:45:a5 (c1:1c:4d:4f:45:a5)
Manufacturer Specific: Apple (length 26, type 0xFF, 0x004C
Data: 0215 0000000070621001b000001c4d8aa76c 0064 0001 b6

Advertising Address: c2:1c:4d:4f:45:a5 (c2:1c:4d:4f:45:a5)
Data: 0215 249bf7f4546c1801ba01001c4d4d98a6 000d c40f b6
*/

struct Peripheral: Comparable {
	static func < (lhs: Peripheral, rhs: Peripheral) -> Bool {
		return lhs.name < rhs.name
	}
	
	let name: String
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate {
	let bluetoothCache = CoreBluetoothCache()
	@IBOutlet weak var tableView: UITableView!
	var central: CBCentralManager!
	var peripherals: [UUID:Peripheral] = [:]
	var displayOrder: [UUID] = []
	let aquasanaUUID = CBUUID(data: Data([0xFE, 0xF8]))

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		central = CBCentralManager()
		central.delegate = self
	}

	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
		case .poweredOn:
			print("CBCentral state poweredOn")
//			central.scanForPeripherals(withServices: nil, options: nil)
			central.scanForPeripherals(withServices: [aquasanaUUID], options: nil)
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

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		print("Discovered \(peripheral.identifier)")
		let identifier = peripheral.identifier
		let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey]
		print("ManufacturerData: \(manufacturerData)")
		let name = peripheral.name ?? identifier.uuidString
		let displayData = Peripheral(name: name)
		if let currentData = peripherals[identifier] {
			if displayData != currentData {
				let indexPath = IndexPath(row: displayOrder.firstIndex(of: identifier)!, section: 0)
				peripherals[identifier] = displayData
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
		} else {
			print("New \(peripheral) \(advertisementData) \(RSSI)")
			let indexPath = IndexPath(row: displayOrder.count, section: 0)
			peripherals[identifier] = displayData
			displayOrder.append(identifier)
			tableView.insertRows(at: [indexPath], with: .automatic)
		}
//		central.stopScan()
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return displayOrder.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BlueToothPeripheral")!
		let nameView = cell.textLabel
		nameView!.text = peripherals[displayOrder[indexPath.row]]!.name
		return cell
	}
	
}

