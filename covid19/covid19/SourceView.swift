//
//  SourceView.swift
//  covid19
//
//  Created by An Trinh on 27/02/2021.
//

import SwiftUI

struct SourceView: View {
    var body: some View {
        NavigationView {
            WebView(request: URLRequest(url: Constants.sourceGovUK))
                .navigationTitle(Text(Constants.sourceGovUKTitle))
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

struct SourceView_Previews: PreviewProvider {
    static var previews: some View {
        SourceView()
    }
}
