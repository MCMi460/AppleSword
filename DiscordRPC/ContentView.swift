//
//  ContentView.swift
//  DiscordRPC
//
//  Created by Deltaion Lee on 12/3/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "x.square.fill")
                .imageScale(.large)
                .foregroundColor(.red)
            Text("Don't run me! Instead, call me in AppleScript!")
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
