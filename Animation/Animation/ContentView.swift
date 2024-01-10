//
//  ContentView.swift
//  Animation
//
//  Created by Kavyashree Hegde on 10/01/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink("Pulse Animation", value: "pulse")
                    NavigationLink("Download Animation", value: "download")
                }
                .navigationDestination(for: String.self) { value in
                    switch value {
                    case "pulse":
                        PulseAnimationView()
                    case "download":
                        DownloadAnimationView()
                    default:
                        EmptyView()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
