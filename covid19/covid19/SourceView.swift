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
                .navigationTitle(Text("Gov.uk Source"))
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SourceView_Previews: PreviewProvider {
    static var previews: some View {
        SourceView()
    }
}
