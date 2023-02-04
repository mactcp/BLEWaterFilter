//
//  ViewController.swift
//  WaterFilter
//
//  Created by Glenn on 4/11/21.
//

/* TODO:
 √ Show something for BlueTooth not authorized
 √ Show something for BlueTooth turned off
 * Save and restore data
 * Default name
 * Edit name
 * MAC address tool tip
 */

import Cocoa
import CoreBluetooth
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
	var lastUpdate: Date
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate {
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var bluetoothStatusLabel: NSTextField!

	static let serviceUUID = CBUUID(data: Data([0xFE, 0xF8])) //Aplix Corporation
	static let manufacturerID: [UInt8] = [0xbd, 0x00] //Aplix Corporation
//	static let beaconUUID1Bytes: uuid_t = (0x00, 0x00, 0x00, 0x00, 0x70, 0x62, 0x10, 0x01, 0xb0, 0x00, 0x00, 0x1c, 0x4d, 0x8a, 0xa7, 0x6c)
//	static let beaconUUID2Bytes: uuid_t = (0x24, 0x9b, 0xf7, 0xf4, 0x54, 0x6c, 0x18, 0x01, 0xba, 0x01, 0x00, 0x1c, 0x4d, 0x4d, 0x98, 0xa6)
//	static let beaconUUID1 = UUID(uuid: beaconUUID1Bytes)
//	static let beaconUUID2 = UUID(uuid: beaconUUID2Bytes)

	static let columnIdentifierName = NSUserInterfaceItemIdentifier(rawValue: "name")
	static let columnIdentifierVolume = NSUserInterfaceItemIdentifier(rawValue: "volume")
	static let columnIdentifierDays = NSUserInterfaceItemIdentifier(rawValue: "days")
	static let columnIdentifierUpdate = NSUserInterfaceItemIdentifier(rawValue: "update")

	let bluetoothCache = CoreBluetoothCache()
	var central: CBCentralManager!
	var peripherals: [UUID:WaterFilter] = [:]
	var displayOrder: [UUID] = []

	private func updateCentralState() {
		let state = central.state
		bluetoothStatusLabel.isHidden = state == .poweredOn
		switch central.state {
		case .poweredOn:
			return //Hidden
		case .resetting:
			bluetoothStatusLabel.stringValue = "Bluetooth resetting"
		case .unsupported:
			bluetoothStatusLabel.stringValue = "Bluetooth unsupported"
		case .unauthorized:
			bluetoothStatusLabel.stringValue = "Bluetooth not authorized"
		case .poweredOff:
			bluetoothStatusLabel.stringValue = "Bluetooth turned off"
		case .unknown:
			fallthrough
		@unknown default:
			bluetoothStatusLabel.stringValue = "Bluetooth state unknown"
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		central = CBCentralManager()
		central.delegate = self
		//Test data
//		let displayData = WaterFilter(name: "Test", volume: 4567, days: 123)
//		let identifier = UUID()
//		peripherals[identifier] = displayData
//		displayOrder.append(identifier)
//		tableView.reloadData()
		updateCentralState()
	}

	internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
		updateCentralState()
		switch central.state {
		case .poweredOn:
			os_log("CBCentral state poweredOn")
//			central.scanForPeripherals(withServices: nil, options: nil)
			central.scanForPeripherals(withServices: [Self.serviceUUID], options: nil)
		case .unknown:
			os_log("CBCentral state unknown")
		case .resetting:
			os_log("CBCentral state resetting")
		case .unsupported:
			os_log("CBCentral state unsupported")
		case .unauthorized:
			os_log("CBCentral state unauthorized")
		case .poweredOff:
			os_log("CBCentral state poweredOff")
		@unknown default:
			os_log("CBCentral state unknown")
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
			let displayData = WaterFilter(name: name, volume: volume, days: days, lastUpdate: Date())
			if let currentData = peripherals[identifier] {
				if displayData != currentData {
					let displayIndex = displayOrder.firstIndex(of: identifier)!
					peripherals[identifier] = displayData
					tableView.reloadData(forRowIndexes: IndexSet(integer: displayIndex), columnIndexes: IndexSet(integersIn: 0...2))
				}
			} else {
				os_log("New %{public}@ %{public}@ %@", peripheral, advertisementData, RSSI)
				peripherals[identifier] = displayData
				let displayIndex = displayOrder.count
				displayOrder.append(identifier)
				tableView.insertRows(at: IndexSet(integer:displayIndex), withAnimation: .effectFade)
			}
		}
//		central.stopScan()
	}


	internal func numberOfRows(in tableView: NSTableView) -> Int {
		return displayOrder.count
	}

//	internal func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
//		let peripheral = peripherals[displayOrder[row]]!
//		switch tableColumn?.identifier {
//		case ViewController.columnIdentifierName:
//			return peripheral.name as NSString
//		case ViewController.columnIdentifierVolume:
//			return peripheral.volume
//		case ViewController.columnIdentifierDays:
//			return peripheral.days
//		case .none:
//			return nil
//		case .some(_):
//			return nil
//		}
//	}
	
	internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let identifier = tableColumn?.identifier else {
			return nil
		}
		let peripheral = peripherals[displayOrder[row]]!
		switch identifier {
		case Self.columnIdentifierName:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = peripheral.name
			return view
		case Self.columnIdentifierVolume:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = "\(peripheral.volume)"
			return view
		case Self.columnIdentifierDays:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = "\(peripheral.days)"
			return view
		case Self.columnIdentifierUpdate:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = "\(peripheral.lastUpdate)"
			return view
		default:
			return nil
		}
	}
}

