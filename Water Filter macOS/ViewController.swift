//
//  ViewController.swift
//  WaterFilter
//
//  Created by Glenn Anderson on 4/11/2021.
//

/* TODO:
 √ Show something for BlueTooth not authorized
 √ Show something for BlueTooth turned off
 √ Save and restore data
 √ Edit name
 * Default name
 * MAC address tool tip
 • Remove filter
 • Scanning mode?
 */

import Cocoa
import CoreBluetooth
import OSLog

let kDefaultsWaterFilters = "waterFilters"
let kDefaultsWaterFilterID = "uuid"
let kDefaultsWaterFilterName = "name"
let kDefaultsWaterFilterVolume = "volume"
let kDefaultsWaterFilterDays = "days"
let kDefaultsWaterFilterLastUpdate = "lastUpdate"

struct WaterFilter {
	var name: String
	var volume: UInt32
	var days: UInt8
	var lastUpdate: Date
	var macAddress: String?
	
	mutating func update(volume newVolume: UInt32, days newDays: UInt8, lastUpdate newUpdate: Date) {
		volume = newVolume
		days = newDays
		lastUpdate = newUpdate
	}
}

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, CBCentralManagerDelegate, NSTextFieldDelegate {
	@IBOutlet weak var tableView: NSTableView!
	@IBOutlet weak var bluetoothStatusLabel: NSTextField!

	let serviceUUID = CBUUID(data: Data([0xFE, 0xF8])) //Aplix Corporation
	let manufacturerID: [UInt8] = [0xbd, 0x00] //Aplix Corporation
//	let beaconUUID1Bytes: uuid_t = (0x00, 0x00, 0x00, 0x00, 0x70, 0x62, 0x10, 0x01, 0xb0, 0x00, 0x00, 0x1c, 0x4d, 0x8a, 0xa7, 0x6c)
//	let beaconUUID2Bytes: uuid_t = (0x24, 0x9b, 0xf7, 0xf4, 0x54, 0x6c, 0x18, 0x01, 0xba, 0x01, 0x00, 0x1c, 0x4d, 0x4d, 0x98, 0xa6)
//	let beaconUUID1 = UUID(uuid: beaconUUID1Bytes)
//	let beaconUUID2 = UUID(uuid: beaconUUID2Bytes)

	let columnIdentifierName = NSUserInterfaceItemIdentifier(rawValue: "name")
	let columnIdentifierVolume = NSUserInterfaceItemIdentifier(rawValue: "volume")
	let columnIdentifierDays = NSUserInterfaceItemIdentifier(rawValue: "days")
	let columnIdentifierUpdate = NSUserInterfaceItemIdentifier(rawValue: "update")

	let dateFormatter = DateFormatter()
	
	let bluetoothCache = CoreBluetoothCache()
	var central: CBCentralManager!
	var peripherals: [UUID:WaterFilter] = [:]
	var displayOrder: [UUID] = []

	private func updateCentralState() {
		let state = central.state
		bluetoothStatusLabel.isHidden = state == .poweredOn
		tableView.isEnabled = state == .poweredOn
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
	
	private func loadWaterFilters() {
		if let waterFilters = UserDefaults.standard.object(forKey: kDefaultsWaterFilters) as? [[String : Any]] {
			for waterFilter in waterFilters {
				let identifierData = waterFilter[kDefaultsWaterFilterID] as! Data
				let identifier = identifierData.withUnsafeBytes { buffer in
					buffer.withMemoryRebound(to: uuid_t.self) { buffer in
						UUID(uuid: buffer.baseAddress!.pointee)
					}
				}
				let name = waterFilter[kDefaultsWaterFilterName] as! String
				let volume = waterFilter[kDefaultsWaterFilterVolume] as! UInt32
				let days = waterFilter[kDefaultsWaterFilterDays] as! UInt8
				let lastUpdate = waterFilter[kDefaultsWaterFilterLastUpdate] as! Date
				let displayData = WaterFilter(name: name, volume: volume, days: days, lastUpdate: lastUpdate, macAddress: bluetoothCache.deviceAddress(for: identifier))
				peripherals[identifier] = displayData
				displayOrder.append(identifier)
			}
			if waterFilters.count > 0 {
				tableView.reloadData()
			}
		}
	}
	
	/*private func loadTestData() {
		let displayData = WaterFilter(name: "Test", volume: 4567, days: 123, lastUpdate: Date(), macAddress: "01:23:45:67:89:AB")
		let identifier = UUID()
		peripherals[identifier] = displayData
		displayOrder.append(identifier)
		
		let displayData2 = WaterFilter(name: "Test2", volume: 8901, days: 45, lastUpdate: Date(), macAddress: "FE:DC:BA:98:76:54")
		let identifier2 = UUID()
		peripherals[identifier2] = displayData2
		displayOrder.append(identifier2)
		
		tableView.reloadData()
	}*/
	
	override func viewDidLoad() {
		super.viewDidLoad()

		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .medium

		central = CBCentralManager()
		central.delegate = self
		updateCentralState()

		loadWaterFilters()
		
		//loadTestData()
	}

	internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
		updateCentralState()
		switch central.state {
		case .poweredOn:
			os_log("CBCentral state poweredOn")
//			central.scanForPeripherals(withServices: nil, options: nil)
			central.scanForPeripherals(withServices: [serviceUUID], options: nil)
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
	
	private func saveWaterFilters() {
		var waterFilters = [[String : Any]]()
		for identifier in displayOrder {
			let waterFilter = peripherals[identifier]!
			let uuidData = withUnsafeBytes(of: identifier.uuid) { buffer in
				Data(bytes: buffer.baseAddress!, count: buffer.count)
			}
			let defaultsData: [String : Any] = [kDefaultsWaterFilterID: uuidData, kDefaultsWaterFilterName: waterFilter.name, kDefaultsWaterFilterVolume: waterFilter.volume, kDefaultsWaterFilterDays: waterFilter.days, kDefaultsWaterFilterLastUpdate: waterFilter.lastUpdate]
			waterFilters.append(defaultsData)
		}
		UserDefaults.standard.setValue(waterFilters, forKey: kDefaultsWaterFilters)
	}

	internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		os_log("Discovered %{public}@ %{public}@", String(describing: peripheral.name), String(describing: peripheral.identifier))
		let identifier = peripheral.identifier
		if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.starts(with: manufacturerID) {
			os_log("ManufacturerData: %{public}@", manufacturerData as NSData)
			let volume = (UInt32(manufacturerData[7]) << 8) | UInt32(manufacturerData[8])
			let days = manufacturerData[9]
			let lastUpdate = Date()
			if peripherals[identifier] != nil {
				peripherals[identifier]!.update(volume: volume, days: days, lastUpdate: lastUpdate)
				let displayIndex = displayOrder.firstIndex(of: identifier)!
				tableView.reloadData(forRowIndexes: IndexSet(integer: displayIndex), columnIndexes: IndexSet(integersIn: 1...3))
			} else {
				//TODO: better default name when no name
				let macAddress = bluetoothCache.deviceAddress(for: identifier)
				let defaultName = "Unknown " + ((macAddress != nil) ? macAddress! : identifier.uuidString)
				let name = peripheral.name?.count ?? 0 > 0 ? peripheral.name! : defaultName
				os_log("New %{public}@ %{public}@ %@", peripheral, advertisementData, RSSI)
				peripherals[identifier] = WaterFilter(name: name, volume: volume, days: days, lastUpdate: lastUpdate, macAddress: macAddress)
				let displayIndex = displayOrder.count
				displayOrder.append(identifier)
				tableView.insertRows(at: IndexSet(integer:displayIndex), withAnimation: .effectFade)
			}
			saveWaterFilters()
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
		let btIdentifier = displayOrder[row]
		let peripheral = peripherals[btIdentifier]!
		switch identifier {
		case columnIdentifierName:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			let textField = view.textField!
			textField.stringValue = peripheral.name
			textField.delegate = self
			view.toolTip = peripheral.macAddress ?? btIdentifier.uuidString
			return view
		case columnIdentifierVolume:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = "\(peripheral.volume)"
			return view
		case columnIdentifierDays:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = "\(peripheral.days)"
			return view
		case columnIdentifierUpdate:
			let view = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
			view.textField!.stringValue = dateFormatter.string(from: peripheral.lastUpdate)
			return view
		default:
			return nil
		}
	}

	func controlTextDidEndEditing(_ notification: Notification) {
		//print("controlTextDidEndEditing: \(notification)")
		guard let textField = notification.object as? NSTextField else {
			return
		}
		let row = tableView.row(for: textField)
		if row == -1 {
			return
		}
		let newName = textField.stringValue
		//print("row: \(row) text: \(newName)")
		let identifier = displayOrder[row]
		if newName != peripherals[identifier]!.name {
			peripherals[identifier]!.name = newName
			saveWaterFilters()
		}
	}
}
