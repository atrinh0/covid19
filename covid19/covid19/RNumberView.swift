//
//  RNumberView.swift
//  covid19
//
//  Created by An Trinh on 27/02/2021.
//

import SwiftUI

struct RNumberView: View {
    var body: some View {
        NavigationView {
            WebView(request: URLRequest(url: Constants.rNumberUK))
                .navigationTitle(Text(Constants.rNumberUKTitle))
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct RNumberView_Previews: PreviewProvider {
    static var previews: some View {
        RNumberView()
    }
}
