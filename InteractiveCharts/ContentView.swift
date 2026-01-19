//
//  ContentView.swift
//  InteractiveCharts
//
//  Created by Sean Veal on 1/19/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeView()
                .navigationTitle("Interactive Chart's")
        }
    }
}

#Preview {
    ContentView()
}
