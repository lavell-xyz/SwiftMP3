// Copyright © 2019 Allan Lavell
//
// See LICENSE in root folder for more info

import SwiftUI
import Combine

struct LoginView: View {
    var spotify: Spotify
   
    var body: some View {
        ZStack {
           Color.black
           .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 100) {
                LoginButton(spotify: spotify)
            }
        }
    }
}

struct LoginButton: View {
    var spotify: Spotify
    
    var body: some View {
        Button(action: {
            self.spotify.connect()
        }) {
            Image(systemName: "power")
            .font(Font.system(size: 120, weight: .regular))
            .foregroundColor(Color.white)
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let spotify = Spotify.shared
        return LoginView(spotify: spotify)
    }
}
#endif
