//
//  BluetoothTableView.swift
//  Water Filter macOS
//
//  Created by Glenn Anderson on 6/29/2023.
//  © Copyright 2023 Glenn Anderson
//

import Cocoa

class BluetoothTableView: NSTableView {
	@MainActor
	override func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		print("BluetoothTableView validateUserInterfaceItem: \(item)")
		switch item.action {
		case #selector(NSText.delete(_:))?:
			//TODO: if water filter selected
			return true
		default:
			return false
		}
	}
}
