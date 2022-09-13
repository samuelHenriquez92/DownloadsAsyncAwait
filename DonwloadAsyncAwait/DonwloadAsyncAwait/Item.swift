//
//  Character.swift
//  DonwloadAsyncAwait
//
//  Created by Samuel Henriquez on 9/12/22.
//

struct Item: Codable {
    let id: String
    let urls: URLImage
    let links: LinkImage
}

struct URLImage: Codable {
    let full: String
    let thumb: String
    let regular: String
}

struct LinkImage: Codable {
    let download: String
}
