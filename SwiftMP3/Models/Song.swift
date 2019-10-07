// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import Foundation

let maxNameLength = 28

struct Song: Identifiable, Equatable {
    var id: String
    var coverArt: UIImage?
    var name: String
    var artist: String
    
    init(item: SPTAppRemoteContentItem) {
        self.id = item.uri
        self.name = item.title!.truncate(length: maxNameLength)
        self.artist = extractArtistName(subtitle: item.subtitle!).truncate(length: maxNameLength)
    }
    
    init(track: SPTAppRemoteTrack) {
        self.id = track.uri
        self.name = track.name.truncate(length: maxNameLength)
        self.artist = track.artist.name.truncate(length: maxNameLength)
    }
    
    init(id: String, name: String, artist: String) {
        self.id = id
        self.name = name
        self.artist = artist
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

private func extractArtistName(subtitle: String) -> String {
    let range = subtitle.range(of: "•")!
    return String(subtitle[subtitle.index(range.lowerBound, offsetBy: 2)...])
}
