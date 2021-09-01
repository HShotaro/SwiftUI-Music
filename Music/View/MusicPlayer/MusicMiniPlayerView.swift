//
//  MusicMiniPlayerView.swift
//  Music
//
//  Created by Shotaro Hirano on 2021/09/01.
//

import SwiftUI

struct MusicMiniPlayerView: View {
    static let height: CGFloat = 80
    @EnvironmentObject var playerManager: MusicPlayerManager
    @State var image: UIImage = UIImage(systemName: "photo") ?? UIImage()
    @State var offset: CGFloat = 0
    @Binding var expand: Bool
    var animation: Namespace.ID
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 15) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: expand ? .fit : .fill)
                    .frame(width: expand ? 300 : 55, height: expand ? 300 : 55)
                    .cornerRadius(15)
                if !expand {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(playerManager.currentTrack?.name ?? "")
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(expand ? 2 : 1)
                            .matchedGeometryEffect(id: "current_track_name", in: animation)
                        Text(playerManager.currentTrack?.artist.name ?? "")
                            .font(.subheadline)
                            .lineLimit(1)
                            .matchedGeometryEffect(id: "current_track_artist_name", in: animation)
                    }
                    Spacer(minLength: 0)
                    Button {
                        playerManager.playButtonSelected()
                    } label: {
                        Image(systemName: playerManager.onPlaying ? "pause" : "play.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .matchedGeometryEffect(id: "play_track", in: animation)
                    }
                    
                    Button {
                        playerManager.nextButtonSelected()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .matchedGeometryEffect(id: "forward_track", in: animation)
                    }
                }
            }
            .padding(.horizontal)
            if expand {
                Text(playerManager.currentTrack?.name ?? "")
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding([.leading, .bottom, .trailing])
                    .matchedGeometryEffect(id: "current_track_name", in: animation)
                Text(playerManager.currentTrack?.artist.name ?? "")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding([.leading, .bottom, .trailing])
                    .matchedGeometryEffect(id: "current_track_artist_name", in: animation)
                HStack(alignment: .center, spacing: 50) {
                    Button(action: {
                        playerManager.backButtonSelected()
                    }, label: {
                        Image(systemName: "backward.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                    })
                    .frame(width: 50, height: 50)
                    .disabled(playerManager.isFirstTrack)
                    Button(action: {
                        playerManager.playButtonSelected()
                    }, label: {
                        Image(systemName: playerManager.onPlaying ? "pause" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .matchedGeometryEffect(id: "play_track", in: animation)
                    })
                    .frame(width: 50, height: 50)
                    Button(action: {
                        playerManager.nextButtonSelected()
                    }, label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .matchedGeometryEffect(id: "forward_track", in: animation)
                    })
                    .frame(width: 50, height: 50)
                }
            }
        }
        .onChange(of: playerManager.currentTrack, perform: { _ in
            DispatchQueue.global().async {
                if let url = playerManager.currentTrack?.album.imageURL {
                    downloadImageAsync(url: url) { image in
                        self.image = image ?? UIImage()
                    }
                }
            }
        })
        .frame(maxWidth: .infinity, maxHeight: expand ? .infinity : MusicMiniPlayerView.height)
        .background(
            VStack(spacing: 0) {
                BlurView()
                Divider()
            }.onTapGesture {
                withAnimation(.spring()) {
                    expand.toggle()
                }
            }
        )
        .cornerRadius(expand ? 20 : 0)
        .offset(y: expand ? 0 : -48)
        .offset(y: offset)
        .gesture(DragGesture().onEnded(didEnd(value:)).onChanged(didChange(value:)))
        .ignoresSafeArea()
    }
    
    private func didChange(value: DragGesture.Value) {
        if value.translation.height > 0 && expand {
            offset = value.translation.height
        }
    }
    
    private func didEnd(value: DragGesture.Value) {
        withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.95, blendDuration: 0.95)) {
            if value.translation.height > 300 {
                expand = false
            }
            offset = 0
        }
    }
}

struct MusicMiniPlayerView_Previews: PreviewProvider {
    @Namespace static var animation
    @State static var state = false
    static var previews: some View {
        MusicMiniPlayerView(expand: $state, animation: animation)
            .environmentObject(MusicPlayerManager.shared)
    }
}
