//
//  ContentView.swift
//  VCapp
//
//  Created by abdullah on 14/01/1444 AH.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var TimeModel: TimeViewModel
    var body: some View {
        Home()
            .environmentObject(TimeModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
