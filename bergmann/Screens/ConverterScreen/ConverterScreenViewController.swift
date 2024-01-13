//
//  ConverterScreenViewController.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 09.01.2024.
//

import UIKit

protocol ConverterScreenViewControllerLogic: AnyObject {
    func displayCurrencies(_ viewModel: ConverterScreenViewModels.Currencies)
    func displayCurrencyAmounts(_ viewModel: ConverterScreenViewModels.CurrencyAmounts)
    func displayConvert(_ viewModel: ConverterScreenViewModels.Convert)
    func displayChangeCurrency(_ viewModel: ConverterScreenViewModels.ChangeCurrency)
    func displayLoading(_ viewModel: ConverterScreenViewModels.Loading)
    func displayError(_ viewModel: ConverterScreenViewModels.Error)
}

final class ConverterScreenViewController: UIViewController {
    // MARK: - Private properties
    private let interactor: ConverterScreenInteractorLogic
    
    // MARK: - Private UI elements
    private let currencyFromLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    private let currencyFromTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numbersAndPunctuation
        textField.borderStyle = .roundedRect
        return textField
    }()
    private let currencyToLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        return label
    }()
    private let currencyToTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        return textField
    }()
    private let rateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Initialization
    init(interactor: ConverterScreenInteractorLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        setupActions()
        interactor.requestInit(ConverterScreenRequests.Init())
    }
}

// MARK: - ConverterScreenViewControllerLogic

extension ConverterScreenViewController: ConverterScreenViewControllerLogic {
    func displayCurrencies(_ viewModel: ConverterScreenViewModels.Currencies) {
        currencyFromLabel.text = viewModel.from
        currencyToLabel.text = viewModel.to
        rateLabel.text = viewModel.rate
        errorLabel.text = nil
    }
    
    func displayCurrencyAmounts(_ viewModel: ConverterScreenViewModels.CurrencyAmounts) {
        currencyFromTextField.text = viewModel.from
        currencyToTextField.text = viewModel.to
        errorLabel.text = nil
    }

    func displayConvert(_ viewModel: ConverterScreenViewModels.Convert) {
        currencyToTextField.text = viewModel.amount
    }

    func displayChangeCurrency(_ viewModel: ConverterScreenViewModels.ChangeCurrency) {
        showCurrencies(viewModel.currencies, title: viewModel.title, cancelTitle: viewModel.cancelTitle)
    }

    func displayLoading(_ viewModel: ConverterScreenViewModels.Loading) {
        currencyFromTextField.isEnabled = viewModel.isInputEnabled
        currencyFromLabel.isUserInteractionEnabled = viewModel.isInputEnabled
        currencyToLabel.isUserInteractionEnabled = viewModel.isInputEnabled
        errorLabel.text = nil
        if viewModel.isActivityIndicatorVisible {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func displayError(_ viewModel: ConverterScreenViewModels.Error) {
        errorLabel.text = viewModel.error
        currencyToTextField.text = nil
    }
}

// MARK: - Private methods

private extension ConverterScreenViewController {
    func setupView() {
        view.backgroundColor = .white

        view.addSubview(currencyFromLabel)
        view.addSubview(currencyFromTextField)
        view.addSubview(currencyToLabel)
        view.addSubview(currencyToTextField)
        view.addSubview(rateLabel)
        view.addSubview(errorLabel)
        view.addSubview(activityIndicator)
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate(
            [
                currencyFromLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                currencyFromLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                currencyFromLabel.widthAnchor.constraint(equalToConstant: 150)
            ]
        )
        
        NSLayoutConstraint.activate(
            [
                currencyFromTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
                currencyFromTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                currencyFromTextField.widthAnchor.constraint(equalToConstant: 100)
            ]
        )
        
        NSLayoutConstraint.activate(
            [
                currencyToLabel.topAnchor.constraint(equalTo: currencyFromLabel.bottomAnchor, constant: 16),
                currencyToLabel.leadingAnchor.constraint(equalTo: currencyFromLabel.leadingAnchor),
                currencyToLabel.widthAnchor.constraint(equalTo: currencyFromLabel.widthAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [
                currencyToTextField.topAnchor.constraint(equalTo: currencyFromTextField.bottomAnchor, constant: 16),
                currencyToTextField.trailingAnchor.constraint(equalTo: currencyFromTextField.trailingAnchor),
                currencyToTextField.widthAnchor.constraint(equalTo: currencyFromTextField.widthAnchor)
            ]
        )

        NSLayoutConstraint.activate(
            [
                rateLabel.topAnchor.constraint(equalTo: currencyToTextField.bottomAnchor, constant: 16),
                rateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                rateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ]
        )

        NSLayoutConstraint.activate(
            [
                errorLabel.topAnchor.constraint(equalTo: rateLabel.bottomAnchor, constant: 16),
                errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ]
        )

        NSLayoutConstraint.activate(
            [
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    func setupActions() {
        let fromTap = UITapGestureRecognizer(target: self, action: #selector(fromCurrencyDidTap))
        currencyFromLabel.addGestureRecognizer(fromTap)
        let toTap = UITapGestureRecognizer(target: self, action: #selector(toCurrencyDidTap))
        currencyToLabel.addGestureRecognizer(toTap)
        currencyFromTextField.addTarget(self, action: #selector(currencyFromDidChange), for: .editingChanged)
    }
    
    func showCurrencies(_ currencies: [String], title: String, cancelTitle: String) {
        let actionSheet = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { [weak self] _ in
            self?.interactor.requestSetCurrency(ConverterScreenRequests.SetCurrency(index: -1))
        }
        currencies.enumerated().forEach { offset, title in
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.interactor.requestSetCurrency(
                    ConverterScreenRequests.SetCurrency(index: offset)
                )
            }
            actionSheet.addAction(action)
        }
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
    }
    
    @objc func fromCurrencyDidTap() {
        interactor.requestChangeCurrency(ConverterScreenRequests.ChangeCurrency(side: .from))
    }
    
    @objc func toCurrencyDidTap() {
        interactor.requestChangeCurrency(ConverterScreenRequests.ChangeCurrency(side: .to))
    }
    
    @objc func currencyFromDidChange() {
        interactor.requestConvert(ConverterScreenRequests.Convert(amount: currencyFromTextField.text))
    }
}
