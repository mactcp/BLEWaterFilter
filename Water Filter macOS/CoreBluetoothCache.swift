//
//  CoreBluetoothCache.swift
//  WaterFilter
//
//  Created by Glenn Anderson on 3/18/2021.
//

import Foundation

//plutil -p /Library/Preferences/com.apple.Bluetooth.plist
//CoreBluetoothCache
//DeviceAddress

class CoreBluetoothCache: NSObject {
	var deviceCache: [String: Any]?
	let defaults = UserDefaults.init(suiteName: "com.apple.Bluetooth")!
	
	override init() {
		super.init()
		deviceCache = defaults.dictionary(forKey: "CoreBluetoothCache")
//			print("defaults: \(deviceCache!)")
		defaults.addObserver(self, forKeyPath: "CoreBluetoothCache", options: [.new, .initial], context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let change = change, let changeKind = change[.kindKey] as? UInt, changeKind == NSKeyValueChange.setting.rawValue {
			if let changeValue = change[.newKey] as? [String: Any] {
//				print("Setting cache to: \(changeValue)")
				deviceCache = changeValue
			}
		}
	}
	
	public func deviceAddress(for uuid: UUID) -> String? {
		guard let deviceCache = deviceCache, let deviceRecord = deviceCache[uuid.uuidString] as? Dictionary<String,Any> else {
			return nil
		}
		return deviceRecord["DeviceAddress"] as? String
	}
}
