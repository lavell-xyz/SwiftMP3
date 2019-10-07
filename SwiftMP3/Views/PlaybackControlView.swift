// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI

struct PlaybackControlView: View {
    var spotify: Spotify
    
    var body: some View {
        ZStack {
            Color(white: 0.1)
           .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 25.0) {
                SongTitle(spotify: spotify, name: "", artist: "")
                HStack(alignment: .center, spacing: 40.0) {
                    PrevButton(spotify: spotify)
                    PlayPauseButton(spotify: spotify, isPlaying: true)
                    NextButton(spotify: spotify)
                }
            }            
        }
    }
}

struct SongTitle: View {
    var spotify: Spotify
    @State var name: String
    @State var artist: String
    
    var body: some View {
        HStack {
            Text(name)
            .font(Font.system(size: 18, weight: .bold))
            .foregroundColor(Color.white)
            
            Text("• \(artist)")
            .font(Font.system(size: 18, weight: .regular))
            .foregroundColor(Color.white)
        }.onReceive(self.spotify.currentSong) { currentSong in
            if let s = currentSong {
                self.name = s.name
                self.artist = s.artist
            }
        }
    }
}

struct PlayPauseButton: View {
    var spotify: Spotify
    @State var isPlaying: Bool
    
    var body: some View {
        Button(action: {
            self.spotify.togglePlayback()
        }) {
            Image(systemName: !self.isPlaying ? "play.fill" : "pause.fill")
            .font(Font.system(size: 30, weight: .regular))
            .foregroundColor(Color.white)
            .frame(width: 50.0, height: 50.0, alignment: .center)
        }.onReceive(self.spotify.playbackState) { playbackState in
            self.isPlaying = playbackState
        }
    }
}

struct PrevButton: View {
    var spotify: Spotify
    
    var body: some View {
        Button(action: {
            self.spotify.prev()
        }) {
            Image(systemName: "backward.fill")
            .font(Font.system(size: 24, weight: .thin))
            .foregroundColor(Color.white)
            .frame(width: 50.0, height: 50.0, alignment: .center)
        }
    }
}

struct NextButton: View {
    var spotify: Spotify
    
    var body: some View {
        Button(action: {
            self.spotify.next()
        }) {
            Image(systemName: "forward.fill")
            .font(Font.system(size: 24, weight: .regular))
            .foregroundColor(Color.white)
                .frame(width: 50.0, height: 50.0, alignment: .center)
        }
    }
}

#if DEBUG
struct PlaybackControlView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackControlView(spotify: Spotify.shared)
    }
}
#endif
