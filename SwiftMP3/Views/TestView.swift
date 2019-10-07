// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI

struct TestView: View {
    @State var songList: [TestSong]
    
    var body: some View {
        ZStack {
            Text("Hello world")
            .font(Font.system(size: 40, weight: .bold))
            List(self.songList) { song in
                Text(song.title)
            }
        }
    }
}

#if DEBUG
struct TestView_Previews: PreviewProvider {
    static var songList: [TestSong] {
        [
            TestSong(title: "The Art of Gibberish", coverArt:  nil),
            TestSong(title: "The Art of Gibberish II", coverArt:  nil),
        ]
    }

    static var previews: some View {
        ZStack {
            TestView(songList: self.songList)
        }
        
//            .colorScheme(.dark)
    }
}
#endif

struct TestSong: Identifiable {
    var id: String {
        return title
    }
    
    var title: String
    var coverArt: UIImage?
}

//        VStack() {
//            List(songList) { song in
//                HStack(alignment: .center, spacing: 32.0, content: {
//                    Image(uiImage: song.coverArt ?? UIImage(named: "Placeholder")!)
//                    .resizable()
//                        .frame(width: 64.0, height: 64.0)
//                    Button("\(song.title)", action: {
//
//                    }).frame(minWidth: 50.0, idealWidth: 200.0, maxWidth: 200.0, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
//                })
//            }
//        }
