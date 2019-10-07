// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import Foundation
import Combine

class Spotify: NSObject, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    static let shared = Spotify()
    var songList = CurrentValueSubject<[Song], Never>([])
    var currentSong = CurrentValueSubject<Song?, Never>(nil)
    var playbackState = CurrentValueSubject<Bool, Never>(true)
    var isLoggedIn = CurrentValueSubject<Bool, Never>(false)
    
    let spotifyClientID = ""
    let spotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: self.configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = SPTAppRemoteAccessTokenKey

    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )
    
    public func connect() {
        self.appRemote.authorizeAndPlayURI("")
    }
    
    public func togglePlayback() {
        if self.playbackState.value == true {
            self.pause()
        }
        else {
            Spotify.shared.appRemote.playerAPI?.resume(nil)
            self.playbackState.value = true
        }
    }
    
    public func pause() {
        self.appRemote.playerAPI?.pause()
        self.playbackState.value = false
    }
    
    public func play(item: APIItem) {
        self.appRemote.playerAPI?.play(item.item, callback: nil)
        self.playbackState.value = true
    }
    
    public func play(uri: String) {
        self.appRemote.playerAPI?.play(uri, callback: nil)
    }
    
    public func next() {
        // custom skip, as playerAPI's skip does not behave as you might expect
        if let currentSong = currentSong.value {
            var i = 0
            for song in songList.value {
                if currentSong.id == song.id {
                    if i + 1 < songList.value.count {
                        self.appRemote.playerAPI?.play(songList.value[i+1].id, callback: nil)
                    }
                    else {
                        self.appRemote.playerAPI?.skip(toNext: nil)
                    }
                    break
                }
                i += 1
            }
        }
        else {
            self.appRemote.playerAPI?.play(songList.value[0].id, callback: nil)
        }
    }
    
    public func prev() {
        if let currentSong = currentSong.value {
            var i = 0
            for song in songList.value {
                if currentSong.id == song.id {
                    if i - 1 >= 0 {
                        self.appRemote.playerAPI?.play(songList.value[i-1].id, callback: nil)
                    }
                    else {
                        self.appRemote.playerAPI?.skip(toPrevious: nil)
                    }
                    break
                }
                i += 1
            }
        }
        else {
            self.appRemote.playerAPI?.play(songList.value[0].id, callback: nil)
        }
    }
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote.playerAPI?.delegate = self
        // confusing: the subscription doesnt actually call the callback for each change.
        // instead, it invokes the delegate methods
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in})
        
        self.isLoggedIn.value = true
        DispatchQueue.main.async {
            self.playbackState.value = true
        }
        getSongList()
    }
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if self.currentSong.value != nil {
            if playerState.track.uri != self.currentSong.value!.id {
                self.currentSong.value = Song(track: playerState.track)
            }
        }
        else {
            self.currentSong.value = Song(track: playerState.track)
        }
    }
    
    func open(url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = access_token
            self.accessToken = access_token
            self.appRemote.connect()
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
          // Show the error
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let _ = self.appRemote.connectionParameters.accessToken {
            self.appRemote.connect()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        if self.appRemote.isConnected {
            self.appRemote.disconnect()
        }
    }
    
    func apiDive(apiItem: APIItem?) -> Future<[APIItem], Never> {
        return Future<[APIItem], Never> { promise in
            if let apiItem = apiItem {
                self.appRemote.contentAPI!.fetchChildren(of: apiItem.item) { (result, error) in
                    if let remoteContentItemArray = result as? [SPTAppRemoteContentItem] {
                        let apiItems = remoteContentItemArray.map { (item) -> APIItem in
                            APIItem(item: item)
                        }
                        promise(.success(apiItems))
                    }
                }
            }
            else {
                self.appRemote.contentAPI!.fetchRootContentItems(forType: SPTAppRemoteContentTypeFitness) { (result, error) in
                    if let remoteContentItemArray = result as? [SPTAppRemoteContentItem] {
                        let apiItems = remoteContentItemArray.map { (item) -> APIItem in
                            APIItem(item: item)
                        }
                        promise(.success(apiItems))
                    }
                }
            }
        }
    }
    
    func getSongList() {
        self.appRemote.contentAPI!.fetchRootContentItems(forType: SPTAppRemoteContentTypeDefault, callback: { (result, error) in
            if let r = result as? NSArray {
                print(r)
                for x in r {
                    if let x = x as? SPTAppRemoteContentItem {
                        print(x.title)
                        if x.isContainer {
//                            self.appRemote.fetchChildrenOf
                            self.appRemote.contentAPI!.fetchChildren(of: x) { (result, error) in
                                if let r = result as? NSArray {
                                    for x in r {
                                        if let x = x as? SPTAppRemoteContentItem {
                                            print("> \(x.title)")
                                            
                                            if x.title == "Albums" {
                                                self.appRemote.contentAPI!.fetchChildren(of: x) { (result, error) in
                                                    if let r = result as? NSArray {
                                                        for x in r {
                                                            if let x = x as? SPTAppRemoteContentItem {
                                                                print(">> album: \(x.title)")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            else if x.title == "Liked Songs" {
                                                self.appRemote.contentAPI!.fetchChildren(of: x) { (result, error) in
                                                    if let r = result as? NSArray {
                                                        for x in r {
                                                            if let x = x as? SPTAppRemoteContentItem {
//                                                                print(">> \(x.title)s")
                                                                var song = Song(item: x)
                                                                self.appRemote.imageAPI!.fetchImage(forItem: x, with: CGSize(width: 64, height: 64)) { (result, error) in
                                                                    if let image = result as? UIImage {
                                                                        var i = 0
                                                                        while i < self.songList.value.count {
                                                                            if self.songList.value[i] == song {
                                                                                break
                                                                            }
                                                                            i += 1
                                                                        }
                                                                        
                                                                        song.coverArt = image

                                                                        self.songList.value[i] = song
                                                                        //trying to force a refresh
                                                                        let tempSongList = self.songList.value
                                                                        self.songList.value = []
                                                                        self.songList.value = tempSongList
                                                                    }
                                                                }
                                                                if !self.songList.value.contains(song) {
                                                                    self.songList.value.append(song)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
//            for x in result {
//                print(x)
//            }
            print("content api callback bitzasf")
            print(result)
        })

    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        
    }
}

struct APIItem: Identifiable {
    var item: SPTAppRemoteContentItem
    
    var id: String {
        self.item.identifier
    }
}
