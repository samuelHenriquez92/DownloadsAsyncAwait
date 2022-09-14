//
//  ContentViewModel.swift
//  DonwloadAsyncAwait
//
//  Created by Samuel Henriquez on 9/12/22.
//

import SwiftUI

final class ContentViewModel: ObservableObject {

    // MARK: - Variables Definition

    enum State {
        case idle
        case downloading
        case downloaded
        case error
    }

    private let persistanceService: UserDefaults
    private let apikey = "238upBGdOHkLLxQgCyTVH9w3a68AhI6tdMWmhHCAKIw"
    private let secret = "kfgHU0bu7DI6Qad6AJg9Hs7bTJwwHYe11nVdltdit7M"
    private let defaultsKey = "imageKey"

    @Published var state: State = .idle
    @Published var image: Image?
    @Published var message: String = ""

    var isDownloaded: Bool {
        image != nil
    }

    // MARK: - Initializers

    init(
        persistanceService: UserDefaults = .standard
    ) {
        self.persistanceService = persistanceService
        initialSetup()
    }

    // MARK: - Public Methods

    func evaluate() async {
        if isDownloaded {
            delete()
            image = nil
            state = .idle
        } else {
            await download()
        }
    }

    // MARK: - Private Methods

    @MainActor
    private func download() async {
        Task {
            state = .downloading
            if let item = await fetch() {
                if let data = await downloadImage(with: item.urls.full) {
                    image = createImage(data)
                    state = .downloaded
                }
            }
        }
    }

    private func buildURLRequest() -> URLRequest {
        var request = URLRequest(url: .init(string: "https://api.unsplash.com/photos/random?client_id=\(apikey)")!)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        return request
    }

    private func fetch() async -> Item? {
        let request = buildURLRequest()
        message = "Getting random image ..."

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                setupError()
                throw APIError.invalidServerResponse
            }
            return try Item(data: data)
        } catch {
            setupError()
            return nil
        }
    }

    private func downloadImage(with url: String) async -> Data? {
        do {
            let (asyncBytes, urlResponse) = try await URLSession.shared.bytes(from: .init(string: url)!)
            let length = (urlResponse.expectedContentLength)
            var data = Data()
            data.reserveCapacity(Int(length))
            var previous = 0

            for try await byte in asyncBytes {
                data.append(byte)
                let progress = Int((Double(data.count) / Double(length)) * 100)
                if previous < progress {
                    DispatchQueue.main.async { [weak self] in
                        self?.message = "\(progress) % downloaded"
                    }
                    previous = progress
                }
                if progress == 100 { // Completed
                    save(data)
                }
            }
            return data
        } catch {
            setupError()
            return nil
        }
    }

    private func createImage(_ value: Data) -> Image {
        #if canImport(UIKit)
        let image: UIImage = UIImage(data: value) ?? UIImage()
        return Image(uiImage: image)
        #endif
    }

    private func setupError() {
        DispatchQueue.main.async { [weak self] in
            self?.state = .error
        }
    }

    private func initialSetup() {
        if let data = get() {
            image = createImage(data)
            state = .downloaded
        }
    }
}

extension ContentViewModel {
    private func save(_ data: Data) {
        persistanceService.set(data, forKey: defaultsKey)
    }

    private func get() -> Data? {
        persistanceService.data(forKey: defaultsKey)
    }

    private func delete() {
        persistanceService.removeObject(forKey: defaultsKey)
    }
}
