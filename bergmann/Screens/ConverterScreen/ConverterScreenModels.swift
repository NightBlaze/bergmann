//
//  ConverterScreenModels.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 09.01.2024.
//

import Foundation

enum ConverterScreenModels {
    enum Currency: String, CaseIterable, Comparable {
        case rub, usd, eur , gbp, chf, cny
        
        var title: String {
            switch self {
            case .rub:
                return "Rubles"
            case .usd:
                return "US Dollars"
            case .eur:
                return "Euro"
            case .gbp:
                return "British Pound"
            case .chf:
                return "Swiss Franc"
            case .cny:
                return "Chinese Yuan"
            }
        }

        var code: String { rawValue.uppercased() }
        
        static func < (lhs: ConverterScreenModels.Currency, rhs: ConverterScreenModels.Currency) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum CurrencySide {
        case from, to
    }

    // Just an example.
    enum Error {
        case internalError, apiError
    }
}

enum ConverterScreenRequests {
    struct Init { }

    struct ChangeCurrency {
        let side: ConverterScreenModels.CurrencySide
    }

    struct SetCurrency {
        let index: Int
    }
    
    struct Convert {
        let amount: String?
    }
}

enum ConverterScreenResponses {
    struct Currencies {
        let from: ConverterScreenModels.Currency
        let to: ConverterScreenModels.Currency
        let rate: Double?
    }

    struct CurrencyAmounts {
        let from: Double
        let to: Double?
    }

    struct Convert {
        let amount: Double?
    }

    struct Error {
        let error: ConverterScreenModels.Error
    }

    struct Loading {
        let isLoading: Bool
    }

    struct ChangeCurrency {
        let currencies: [ConverterScreenModels.Currency]
    }
}

enum ConverterScreenViewModels {
    struct Currencies {
        let from: String
        let to: String
        let rate: String
    }

    struct CurrencyAmounts {
        let from: String
        let to: String
    }

    struct Convert {
        let amount: String
    }

    struct Error {
        let error: String
    }

    struct Loading {
        let isInputEnabled: Bool
        let isActivityIndicatorVisible: Bool
    }

    struct ChangeCurrency {
        let title: String
        let cancelTitle: String
        let currencies: [String]
    }
}
