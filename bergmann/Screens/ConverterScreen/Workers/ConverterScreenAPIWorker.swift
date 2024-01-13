//
//  ConverterScreenAPIWorker.swift
//  bergmann
//
//  Created by Alexander Timonenkov on 11.01.2024.
//

import Combine
import Foundation

protocol ConverterScreenAPIWorkerDelegate: AnyObject {
    func exchangeRateDidFetch(
        result: Result<ConverterScreenAPIWorker.Models.ResponseDTO, ConverterScreenAPIWorker.Error>
    )
}

protocol ConverterScreenAPIWorkerLogic {
    func fetchRate(from: String, to: String)
}

final class ConverterScreenAPIWorker {
    // MARK: - Nested types
    enum Error: Swift.Error {
        case request
        case urlError(URLError)
        case general(Swift.Error)
    }
    
    enum Models {
        struct RequestDTO: Encodable {
            let from: String
            let to: String
        }
        
        struct ResponseDTO: Decodable {
            let data: [String: Double]
        }
    }
    
    private enum Constants {
        #warning("Set your API key here")
        static let apiKey = "fca_live_EjcREcSVGVaLr9F9Ay4Yiu674CGsnq9tG13DlIfQ"
    }
    
    // MARK: - Internal properties
    weak var delegate: ConverterScreenAPIWorkerDelegate?
    
    // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private let fireRecentSubject = PassthroughSubject<Models.RequestDTO, Never>()
    private var completion: ((Result<Models.ResponseDTO, ConverterScreenAPIWorker.Error>) -> Void)?
    
    init() {
        setupSubject()
    }
}

// MARK: - ConverterScreenAPIWorkerLogic

extension ConverterScreenAPIWorker: ConverterScreenAPIWorkerLogic {
    func fetchRate(
        from: String,
        to: String
    ) {
        fireRecentSubject.send(Models.RequestDTO(from: from, to: to))
    }
}

// MARK: - Private methods

private extension ConverterScreenAPIWorker {
    func request(for dto: Models.RequestDTO) -> URLRequest? {
        let queryItems = [
            URLQueryItem(name: "base_currency", value: dto.from),
            URLQueryItem(name: "currencies", value: dto.to)
        ]
        var urlComponents = URLComponents(string: "https://api.freecurrencyapi.com/v1/latest")
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue(Constants.apiKey, forHTTPHeaderField: "apikey")
        return request
    }

    func dataPublisher(for request: URLRequest?) -> AnyPublisher<Data, Error> {
        guard let request = request else {
            return Fail(error: .request).eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map(\.data)
            .mapError { .urlError($0) }
            .eraseToAnyPublisher()
    }
    
    func setupSubject() {
        fireRecentSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.global())
            .map { self.request(for: $0) }
            .map { self.dataPublisher(for: $0) }
            .switchToLatest()
            .decode(type: Models.ResponseDTO.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: { [weak self] in
                    guard let self = self else { return }
                    if case .failure(let error) = $0 {
                        if let error = error as? Error {
                            self.delegate?.exchangeRateDidFetch(result: .failure(error))
                        } else {
                            self.delegate?.exchangeRateDidFetch(result: .failure(.general(error)))
                        }
                    }
                    self.setupSubject()
                },
                receiveValue: { [weak self] in
                    self?.delegate?.exchangeRateDidFetch(result: .success($0))
                }
            )
            .store(in: &subscriptions)
    }
}
