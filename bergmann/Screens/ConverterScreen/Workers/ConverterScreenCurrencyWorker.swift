//
//  ConverterScreenCurrencyWorker.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 09.01.2024.
//

import Foundation

protocol ConverterScreenCurrencyWorkerLogic {
    var selectedCurrencyFrom: ConverterScreenModels.Currency { get set }
    var selectedCurrencyTo: ConverterScreenModels.Currency { get set }

    func allCurrencies() -> [ConverterScreenModels.Currency]
}

final class ConverterScreenCurrencyWorker: ConverterScreenCurrencyWorkerLogic {
    // MARK: - Nested types
    private enum Constants {
        static let selectedCurrencyFromKey = "selectedCurrencyFromKey"
        static let selectedCurrencyToKey = "selectedCurrencyToKey"
    }
    
    // MARK: - Private properties
    private let storage: StorageLogic
    
    // MARK: - Initialization
    init(storage: StorageLogic) {
        self.storage = storage
    }
    
    // MARK: - ConverterScreenWorkerLogic
    var selectedCurrencyFrom: ConverterScreenModels.Currency {
        get {
            getCurrency(for: Constants.selectedCurrencyFromKey, default: .rub)
        }
        set {
            set(currency: newValue, key: Constants.selectedCurrencyFromKey)
        }
    }
    
    var selectedCurrencyTo: ConverterScreenModels.Currency {
        get {
            getCurrency(for: Constants.selectedCurrencyToKey, default: .usd)
        }
        set {
            set(currency: newValue, key: Constants.selectedCurrencyToKey)
        }
    }
}

// MARK: - ConverterScreenCurrencyWorkerLogic

extension ConverterScreenCurrencyWorker {
    func allCurrencies() -> [ConverterScreenModels.Currency] {
        ConverterScreenModels.Currency.allCases.sorted(by: <)
    }
}

// MARK: - Private methods

private extension ConverterScreenCurrencyWorker {
    func getCurrency(for key: String, default: ConverterScreenModels.Currency) -> ConverterScreenModels.Currency {
        guard
            let rawValue = storage.get(key: key),
            let currency = ConverterScreenModels.Currency(rawValue: rawValue)
        else {
            return `default`
        }
        
        return currency
    }
    
    func set(currency: ConverterScreenModels.Currency, key: String) {
        storage.set(value: currency.rawValue, key: key)
    }
}
