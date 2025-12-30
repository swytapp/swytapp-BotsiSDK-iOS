//
//  BotsiHeroImageView.swift
//  Botsi
//
//  Created by Konstantin on 14.07.2025.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI
import Combine

@available(iOS 15.0, *)
public struct BotsiHeroImageView: View {
    
    let model: BotsiHeroImageModel

    public var body: some View {
        switch model.style {
        case .transparent:
            ZStack {
                Color.clear
                    .background(
                        BotsiHeroImage(imageURL: model.backgroundImage, type: model.type)
                            .ignoresSafeArea()
                    )
                Color.clear
                    .backgroundFill(model.fillColor)
            }

        case .overlay:
            BotsiHeroImage(imageURL: model.backgroundImage, type: model.type)
        case .flat:
            BotsiHeroImage(imageURL: model.backgroundImage, type: model.type)
        }
    }
}

@available(iOS 15.0, *)
private struct BotsiHeroImage: View {
    
    let imageURL: String?
    let type: String?
    @Environment(\.imageLoadingTracker) private var imageLoadingTracker
    @State private var player = AVPlayer()
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        if let imageURL, let url = URL(string: imageURL) {
            if type == "video" {
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarBackButtonHidden()
                    .scaledToFill()
                    .onAppear {
                        let url = URL(string: imageURL)!
                        player = AVPlayer(url: url)
                        
                        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                                .sink { _ in
                                    player.seek(to: .zero)
                                    player.play()
                                }
                                .store(in: &cancellables)
                        
                        player.currentItem?.publisher(for: \.status)
                                .sink { status in
                                    switch status {
                                    case .readyToPlay:
                                        imageLoadingTracker.onImageComplete(imageURL)
                                    case .failed:
                                        print("Video loading failed")
                                    case .unknown:
                                        imageLoadingTracker.onImageStart(imageURL)
                                    @unknown default:
                                        break
                                    }
                                }
                                .store(in: &cancellables)
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                        cancellables.removeAll()
                    }
            } else {
                AsyncImage(url: url, transaction: Transaction(animation: .none)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .onAppear {
                                imageLoadingTracker.onImageComplete(imageURL)
                            }
                    case .failure(_):
                        Color.gray.opacity(0.2)
                            .onAppear {
                                imageLoadingTracker.onImageComplete(imageURL)
                            }
                    case .empty:
                        Color.gray.opacity(0.2)
                            .onAppear {
                                imageLoadingTracker.onImageStart(imageURL)
                            }
                    @unknown default:
                        Color.gray.opacity(0.2)
                            .onAppear {
                                imageLoadingTracker.onImageComplete(imageURL)
                            }
                    }
                }
                .drawingGroup()
            }
        } else {
            Color.gray.opacity(0.2)
        }
    }
}
