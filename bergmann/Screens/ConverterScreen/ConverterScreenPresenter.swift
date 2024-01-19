//
//  ConverterScreenPresenter.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 09.01.2024.
//

import Foundation

protocol ConverterScreenPresenterLogic {
    func presentCurrencies(_ response: ConverterScreenResponses.Currencies)
    func presentCurrencyAmounts(_ response: ConverterScreenResponses.CurrencyAmounts)
    func presentConvert(_ response: ConverterScreenResponses.Convert)
    func presentChangeCurrency(_ response: ConverterScreenResponses.ChangeCurrency)
    func presentLoading(_ response: ConverterScreenResponses.Loading)
    func presentError(_ response: ConverterScreenResponses.Error)
}

final class ConverterScreenPresenter {
    weak var view: ConverterScreenViewControllerLogic?
}

// MARK: - ConverterScreenPresenterLogic

extension ConverterScreenPresenter: ConverterScreenPresenterLogic {
    func presentCurrencies(_ response: ConverterScreenResponses.Currencies) {
        mainAsync { [weak self] in
            guard let self = self else { return }
            self.view?.displayCurrencies(
                ConverterScreenViewModels.Currencies(
                    from: response.from.title,
                    to: response.to.title,
                    rate: formatRate(response.rate)
                )
            )
        }
    }

    func presentCurrencyAmounts(_ response: ConverterScreenResponses.CurrencyAmounts) {
        mainAsync { [weak self] in
            guard let self = self else { return }
            self.view?.displayCurrencyAmounts(
                ConverterScreenViewModels.CurrencyAmounts(
                    from: self.formatAmount(response.from),
                    to: self.formatAmount(response.to)
                )
            )
        }
    }

    func presentConvert(_ response: ConverterScreenResponses.Convert) {
        mainAsync { [weak self] in
            guard let self = self else { return }
            self.view?.displayConvert(
                ConverterScreenViewModels.Convert(
                    amount: self.formatAmount(response.amount)
                )
            )
        }
    }

    func presentChangeCurrency(_ response: ConverterScreenResponses.ChangeCurrency) {
        view?.displayChangeCurrency(
            ConverterScreenViewModels.ChangeCurrency(
                title: "Currencies",
                cancelTitle: "Cancel",
                currencies: response.currencies.map { $0.title }
            )
        )
    }

    func presentLoading(_ response: ConverterScreenResponses.Loading) {
        mainAsync { [weak self] in
            self?.view?.displayLoading(
                ConverterScreenViewModels.Loading(
                    isInputEnabled: !response.isLoading,
                    isActivityIndicatorVisible: response.isLoading
                )
            )
        }
    }

    func presentError(_ response: ConverterScreenResponses.Error) {
        mainAsync { [weak self] in
            let message: String
            switch response.error {
            case .internalError:
                message = "Some error happend. Please try again later."
            case .apiError:
                message = "Cant get exchange rate for the currencies."
            }
            self?.view?.displayError(
                ConverterScreenViewModels.Error(error: message)
            )
        }
    }
}

// MARK: - Private methods

private extension ConverterScreenPresenter {
    func formatAmount(_ amount: Double?) -> String {
        guard let amount = amount else { return "" }
        return String(format: "%.2f", amount)
    }

    func formatRate(_ rate: Double?) -> String {
        guard let rate = rate else { return "Rate: <unknown>" }
        return "Rate: \(String(format: "%.4f", rate))"
    }
}
