// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI

struct SongListView: View {
    public var spotify: Spotify
    @State public var songList: [Song]
    
    var body: some View {
        List(songList) { song in
            HStack(alignment: .center, spacing: 16.0, content: {
                Image(uiImage: song.coverArt ?? UIImage(named: "Placeholder")!)
                .resizable()
                    .frame(width: 64.0, height: 64.0)
                VStack {
                    Button(action: {
                        self.spotify.play(uri: song.id)
                    }) {
                        Text("\(song.name)")
                            .frame(width: 250.0, height: nil, alignment: .leading)
                            .font(Font.system(size: 17, weight: .bold))
                        Text("\(song.artist)")
                            .frame(width: 250.0, height: nil, alignment: .leading)
                            .font(Font.system(size: 14, weight: .regular))
                            .foregroundColor(Color.gray)
                    }

                }
            })
        }
        .onReceive(spotify.songList) { (list) in
            self.songList = list
        }
    }
}

#if DEBUG
struct SongListView_Previews: PreviewProvider {
    static var previews: some View {
        SongListView(spotify: Spotify.shared, songList: [
            Song(id: "1", name: "Meditate", artist: "Gucci Mayne"),
            Song(id: "2", name: "Land of the Medicine Buddha (Instrumental Meditation with Bamboo Flute, Singing Bowls & Nature Sounds)", artist: "Raresh"),
            Song(id: "3", name: "Pro", artist: "Big Tone")
        ]).colorScheme(.dark)
    }
}
#endif
