//
//  ContentViewModel.swift
//  DonwloadAsyncAwait
//
//  Created by Samuel Henriquez on 9/12/22.
//

import SwiftUI

final class ContentViewModel: ObservableObject {

    // MARK: - Variables Declaration

    enum State {
        case idle
        case downloading
        case error
    }

    @Published var state: State = .idle
    @Published var characters = [Character]()

    var isDownloaded: Bool {
        !characters.isEmpty
    }

    // MARK: - Public Methods

    func evaluate() async {
        if isDownloaded {
            characters.removeAll()
        } else {
            await download()
        }
    }

    @MainActor
    func download() async {
        Task {
            state = .downloading
            characters = await fetch()
            state = .idle
        }
    }

    // MARK: - Private Methods

    private func buildURLRequest() -> URLRequest {
        var request = URLRequest(url: .init(string: "https://swapi.dev/api/people")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        return request
    }

    private func fetch() async -> [Character] {
        // build the request
        let request = buildURLRequest()

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidServerResponse
            }
            return try Result(data: data).results
        } catch {
            return []
        }
    }
}
