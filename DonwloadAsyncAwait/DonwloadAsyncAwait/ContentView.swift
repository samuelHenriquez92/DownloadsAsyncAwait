//
//  ContentView.swift
//  DonwloadAsyncAwait
//
//  Created by Samuel Henriquez on 9/9/22.
//

import CryptoKit
import SwiftUI

struct ContentView: View {

    // MARK: - Variables Declaration

    @StateObject private var viewModel = ContentViewModel()

    // MARK: - View Lifecycle

    var body: some View {
        VStack {
            Button {
                Task { await viewModel.evaluate() }
            } label: {
                Image(systemName: viewModel.isDownloaded ? "trash" : "arrow.down.to.line")
                    .padding()
                    .overlay(
                        Circle()
                            .stroke(.blue, lineWidth: 1)
                    )
                    .padding(2)
            }

            List(viewModel.characters, id: \.name) { character in
                Text(character.name)
            }
            .listStyle(.plain)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
    }
}
