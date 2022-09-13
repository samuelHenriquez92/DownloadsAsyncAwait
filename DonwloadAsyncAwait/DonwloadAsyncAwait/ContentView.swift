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
        NavigationView {
            ZStack {
                switch viewModel.state {
                case .idle:
                    Text("Tap on download icon :D")
                        .foregroundColor(.gray)
                        .bold()

                case .downloading:
                    VStack {
                        ProgressView()
                            .tint(.gray)

                        Text(viewModel.message)
                            .foregroundColor(.gray)
                    }
                case .downloaded:
                    if let image = viewModel.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .ignoresSafeArea(edges: .bottom)
                    }
                case .error:
                    Text("Something was wrong! :(")
                }
            }
            .navigationTitle("AsyncAwait")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.evaluate() }
                    } label: {
                        Image(systemName: viewModel.isDownloaded ? "trash" : "arrow.down.to.line")
                            .animation(.easeIn, value: viewModel.state == .downloading)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
    }
}
