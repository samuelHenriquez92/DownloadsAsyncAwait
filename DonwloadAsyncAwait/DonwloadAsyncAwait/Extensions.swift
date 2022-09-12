//
//  Extensions.swift
//  DonwloadAsyncAwait
//
//  Created by Samuel Henriquez on 9/12/22.
//

import Foundation

extension Result {
    init(
        data: Data
    ) throws {
        self = try JSONDecoder().decode(Result.self, from: data)
    }
}

enum APIError: Error {
    case invalidServerResponse
}
