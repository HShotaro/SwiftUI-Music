//
//  LibraryPlaylistView.swift
//  Music
//
//  Created by Shotaro Hirano on 2021/09/03.
//

import SwiftUI

struct LibraryPlaylistsView: View {
    @StateObject private var viewModel = LibraryPlaylistsViewModel()
    @Binding var destinationView: AnyView?
    @Binding var isPushActive: Bool
    static let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .center), count: 2)
    var body: some View {
        VStack {
            switch viewModel.model {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("loading...")
            case .failed(_):
                VStack {
                    Group {
                        Image("default_icon")
                        Text("ページの読み込みに失敗しました。")
                            .padding(.top, 4)
                    }
                    .foregroundColor(.black)
                    .opacity(0.4)
                    Button(
                        action: {
                            viewModel.onRetryButtonTapped()
                        }, label: {
                            Text("リトライ")
                                .fontWeight(.bold)
                        }
                    )
                    .padding(.top, 8)
                }
            case let .loaded(model):
                ScrollView(.vertical) {
                    LazyVGrid(columns: LibraryPlaylistsView.columns, spacing: 10) {
                            ForEach(model.playlists, id: \.self.id) { playlist in
                                Button {
                                    destinationView = AnyView(PlaylistDetailView(playlistID: playlist.id))
                                    isPushActive = true
                                } label: {
                                    GridItem_Title_SubTitle_Image_View(
                                        titleName: playlist.name,
                                        subTitleName: playlist.creatorName,
                                        imageURL: playlist.imageURL
                                    )
                                }
                            }
                    }.padding(.all, 15)
                }
            }
        }.onAppear {
            viewModel.onAppear()
        }
    }
}

struct LibraryPlaylistsView_Previews: PreviewProvider {
    @State static var anyView: AnyView? = nil
    @State static var isPushActive = false
    static var previews: some View {
        LibraryPlaylistsView(destinationView: $anyView, isPushActive: $isPushActive)
    }
}
