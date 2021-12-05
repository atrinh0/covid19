//
//  RNumberView.swift
//  covid19
//
//  Created by An Trinh on 27/02/2021.
//

import SwiftUI

struct RNumberView: View {
    @State private var reload: Bool = false

    var body: some View {
        NavigationView {
            WebView(url: Constants.rNumberUK, reload: reload)
                .navigationTitle(Text(Constants.rNumberUKTitle))
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button {
                    reload.toggle()
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Font.title2.bold())
                })
        }
        .navigationViewStyle(.stack)
    }
}

struct RNumberView_Previews: PreviewProvider {
    static var previews: some View {
        RNumberView()
    }
}
