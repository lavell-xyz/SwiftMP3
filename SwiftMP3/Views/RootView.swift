// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI

struct RootView: View {
    var spotify: Spotify
    @State var isLoggedIn: Bool
    
    var body: some View {
        Group() {
            if !self.isLoggedIn {
                LoginView(spotify: self.spotify)
            }
            else {
                MainView(spotify: self.spotify)
            }
        }.onReceive(self.spotify.isLoggedIn) { isLoggedIn in
            self.isLoggedIn = isLoggedIn
        }
    }
}
