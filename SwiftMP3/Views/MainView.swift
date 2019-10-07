// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI

struct MainView: View {
    public var spotify: Spotify
    
    var body: some View {
        ZStack {
            Color(white: 0.1).edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    SpacerView(width: nil, height: 60.0)
                    LogoView()
                }
                SongListView(spotify: spotify, songList: [])
                PlaybackControlView(spotify: spotify).frame(minWidth: nil, idealWidth: nil, maxWidth: nil, minHeight: nil, idealHeight: nil, maxHeight: 140, alignment: .center)
            }
        }
    }
}

struct SpacerView: View {
    var width: CGFloat?
    var height: CGFloat?
    
    var body: some View {
        Color.black.opacity(0)
            .frame(width: nil, height: self.height, alignment: .top)
    }
}

struct LogoView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: "waveform.circle.fill")
//            Text("anti-gravity")
        }
        .foregroundColor(Color.white)
        .font(Font.system(size: 40, weight: .regular))
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(spotify: Spotify.shared)
        .colorScheme(.dark)
    }
}
#endif
