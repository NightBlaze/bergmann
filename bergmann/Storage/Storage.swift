//
//  Storage.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 13.01.2024.
//

import Foundation

// Store in UserDefaults for simplicity.

protocol StorageLogic {
    func set(value: String, key: String)
    func get(key: String) -> String?
}

final class Storage {
}

// MARK: - StorageLogic

extension Storage: StorageLogic {
    func set(value: String, key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    func get(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
}
