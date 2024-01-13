//
//  ConverterScreenAssembly.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 09.01.2024.
//

import Foundation

enum ConverterScreenAssembly {
    static func build() -> ConverterScreenViewController {
        let presenter = ConverterScreenPresenter()
        let storage = Storage()
        let currencyWorker = ConverterScreenCurrencyWorker(storage: storage)
        let convertWorker = ConverterScreenConvertWorker(storage: storage)
        let apiWorker = ConverterScreenAPIWorker()
        let interactor = ConverterScreenInteractor(
            presenter: presenter,
            currencyWorker: currencyWorker,
            convertWorker: convertWorker,
            apiWorker: apiWorker
        )
        apiWorker.delegate = interactor
        let view = ConverterScreenViewController(interactor: interactor)
        
        presenter.view = view
        
        return view
    }
}
