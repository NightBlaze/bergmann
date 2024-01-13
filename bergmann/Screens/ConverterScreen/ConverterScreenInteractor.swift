//
//  ConverterScreenInteractor.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 09.01.2024.
//

import Foundation

protocol ConverterScreenInteractorLogic {
    func requestInit(_ request: ConverterScreenRequests.Init)
    func requestChangeCurrency(_ request: ConverterScreenRequests.ChangeCurrency)
    func requestSetCurrency(_ request: ConverterScreenRequests.SetCurrency)
    func requestConvert(_ request: ConverterScreenRequests.Convert)
}

final class ConverterScreenInteractor {
    // MARK: - Nested types
    private enum FetchProgress {
        case inProgress, idle
    }

    // MARK: - Private properties
    private let presenter: ConverterScreenPresenterLogic
    private var currencyWorker: ConverterScreenCurrencyWorkerLogic
    private let convertWorker: ConverterScreenConvertWorkerLogic
    private let apiWorker: ConverterScreenAPIWorkerLogic

    private var fromAmount: Double = 0
    private var changingCurrencySide: ConverterScreenModels.CurrencySide?
    private var changingCurrencies: [ConverterScreenModels.Currency]?
    
    // MARK: - Initialization
    init(
        presenter: ConverterScreenPresenterLogic,
        currencyWorker: ConverterScreenCurrencyWorkerLogic,
        convertWorker: ConverterScreenConvertWorkerLogic,
        apiWorker: ConverterScreenAPIWorkerLogic
    ) {
        self.presenter = presenter
        self.currencyWorker = currencyWorker
        self.convertWorker = convertWorker
        self.apiWorker = apiWorker
    }
}

// MARK: - ConverterScreenInteractorLogic

extension ConverterScreenInteractor: ConverterScreenInteractorLogic {
    func requestInit(_ request: ConverterScreenRequests.Init) {
        presentCurrencies()
        presentCurrencyAmounts()
        fetchExchangeRateIfNeeded()
    }

    func requestChangeCurrency(_ request: ConverterScreenRequests.ChangeCurrency) {
        guard changingCurrencySide == nil, changingCurrencies == nil else { return }
        changingCurrencySide = request.side
        changingCurrencies = currencyWorker.allCurrencies()
        presenter.presentChangeCurrency(
            ConverterScreenResponses.ChangeCurrency(currencies: currencyWorker.allCurrencies())
        )
    }
    
    func requestSetCurrency(_ request: ConverterScreenRequests.SetCurrency) {
        defer {
            changingCurrencySide = nil
            changingCurrencies = nil
        }

        guard
            let changingCurrencySide = changingCurrencySide,
            let changingCurrencies = changingCurrencies,
            request.index >= 0,
            request.index < changingCurrencies.count
        else { return }
        let currency = changingCurrencies[request.index]
        switch changingCurrencySide {
        case .from:
            currencyWorker.selectedCurrencyFrom = currency
        case .to:
            currencyWorker.selectedCurrencyTo = currency
        }

        presentCurrencies()
        if fetchExchangeRateIfNeeded() == .idle {
            presentConvert()
        }
    }

    func requestConvert(_ request: ConverterScreenRequests.Convert) {
        fromAmount = Double(request.amount ?? "") ?? 0
        presentConvert()
    }
}

// MARK: - ConverterScreenAPIWorkerDelegate

extension ConverterScreenInteractor: ConverterScreenAPIWorkerDelegate {
    func exchangeRateDidFetch(
        result: Result<ConverterScreenAPIWorker.Models.ResponseDTO, ConverterScreenAPIWorker.Error>
    ) {
        presenter.presentLoading(ConverterScreenResponses.Loading(isLoading: false))
        switch result {
        case .success(let dto):
            guard let rate = dto.data.values.first else {
                presenter.presentError(ConverterScreenResponses.Error(error: .internalError))
                return
            }
            convertWorker.setRate(
                ConverterScreenConvertWorker.Rate(
                    from: currencyFrom.code,
                    to: currencyTo.code,
                    rate: rate,
                    timestamp: Date().timeIntervalSince1970
                )
            )
            presentCurrencies()
            presentConvert()
        case .failure(let error):
            guard convertWorker.getRate(from: currencyFrom.code, to: currencyTo.code) != nil else {
                // Handle error. Just print it and show error message for simplicity.
                print(error)
                presenter.presentError(ConverterScreenResponses.Error(error: .apiError))
                return
            }
            presentConvert()
        }
    }
}

// MARK: - Private methods

private extension ConverterScreenInteractor {
    var currencyFrom: ConverterScreenModels.Currency { currencyWorker.selectedCurrencyFrom }
    var currencyTo: ConverterScreenModels.Currency { currencyWorker.selectedCurrencyTo }
    var rate: Double? { convertWorker.getRate(from: currencyFrom.code, to: currencyTo.code)?.rate }

    func presentCurrencies() {
        presenter.presentCurrencies(
            ConverterScreenResponses.Currencies(
                from: currencyFrom,
                to: currencyTo,
                rate: rate
            )
        )
    }

    func presentCurrencyAmounts() {
        presenter.presentCurrencyAmounts(
            ConverterScreenResponses.CurrencyAmounts(
                from: fromAmount,
                to: convertWorker.convert(amount: fromAmount, rate: rate)
            )
        )
    }

    func presentConvert() {
        presenter.presentConvert(
            ConverterScreenResponses.Convert(
                amount: convertWorker.convert(amount: fromAmount, rate: rate)
            )
        )
    }

    @discardableResult
    private func fetchExchangeRateIfNeeded() -> FetchProgress {
        guard
            let rate = convertWorker.getRate(from: currencyFrom.code, to: currencyTo.code),
            Date().timeIntervalSince1970 - rate.timestamp < 24 * 60 * 60
        else {
            presenter.presentLoading(ConverterScreenResponses.Loading(isLoading: true))
            apiWorker.fetchRate(
                from: currencyFrom.code,
                to: currencyTo.code
            )
            return .inProgress
        }

        return .idle
    }
}
