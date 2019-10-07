// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI
import Combine

var diveCancellable: AnyCancellable?

struct APIExplorerView: View {
    public var spotify = Spotify.shared
    @State public var apiList: [APIItem]
//    @State public var songList: [Song]
    
    var body: some View {
        VStack(alignment: .center, spacing: 40.0) {
            Button("connect", action: {
                self.spotify.connect()
                
            })
            Button("dive") {
                diveCancellable = self.spotify.apiDive(apiItem: nil).sink(receiveCompletion: {
                    print($0)
                }, receiveValue: { value in
                     self.apiList = value
                })
            }
            List(apiList) { item in
                Button("\(item.item.title!)", action: {
                    if let album = item.item as? SPTAppRemoteAlbum {
                        print("miracle")
                    }
                    if item.item.isContainer {
                        diveCancellable = self.spotify.apiDive(apiItem: item).sink(receiveCompletion: {
                            print($0)
                        }, receiveValue: { value in
                             self.apiList = value
                        })
                    }
                    else if item.item.isPlayable {
                        self.spotify.play(item: item)
                    }
                })
            }
        }
    }
}

#if DEBUG
struct APIExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        APIExplorerView(spotify: Spotify.shared, apiList: [])
    }
}
#endif

