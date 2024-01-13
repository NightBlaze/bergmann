//
//  ConverterScreenConvertWorker.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 13.01.2024.
//

import Foundation

protocol ConverterScreenConvertWorkerLogic {
    func getRate(from: String, to: String) -> ConverterScreenConvertWorker.Rate?
    func setRate(_ rate: ConverterScreenConvertWorker.Rate)
    func convert(amount: Double, rate: Double?) -> Double?
}

final class ConverterScreenConvertWorker {
    // MARK: - Nested types
    struct Rate: Codable {
        let from: String
        let to: String
        let rate: Double
        let timestamp: TimeInterval
    }

    // MARK: - Private properties
    private let storage: StorageLogic
    
    // MARK: - Initialization
    init(storage: StorageLogic) {
        self.storage = storage
    }
}

// MARK: - ConverterScreenConvertWorkerLogic

extension ConverterScreenConvertWorker: ConverterScreenConvertWorkerLogic {
    func getRate(from: String, to: String) -> Rate? {
        guard from.caseInsensitiveCompare(to) != .orderedSame else {
            return Rate(
                from: from,
                to: to,
                rate: 1,
                timestamp: Date.distantFuture.timeIntervalSince1970
            )
        }
        guard
            let rateAsString = storage.get(key: currenciesKey(from: from, to: to)),
            let data = rateAsString.data(using: .utf8),
            let rate = try? JSONDecoder().decode(Rate.self, from: data)
        else { return nil }
        return rate
    }
    
    func setRate(_ rate: Rate) {
        guard
            let data = try? JSONEncoder().encode(rate),
            let rateAsString = String(data: data, encoding: .utf8)
        else { return }
        storage.set(value: rateAsString, key: currenciesKey(from: rate.from, to: rate.to))
    }
    
    func convert(amount: Double, rate: Double?) -> Double? {
        guard let rate = rate else { return nil }
        return amount * rate
    }
}

// MARK: - Private methods

private extension ConverterScreenConvertWorker {
    func currenciesKey(from: String, to: String) -> String {
        "exchange_rate" + from.lowercased() + to.lowercased()
    }
}
