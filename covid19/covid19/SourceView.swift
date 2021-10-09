//
//  SourceView.swift
//  covid19
//
//  Created by An Trinh on 27/02/2021.
//

import SwiftUI

struct SourceView: View {
    @State private var reload: Bool = false

    var body: some View {
        NavigationView {
            WebView(request: URLRequest(url: Constants.sourceGovUK), reload: reload)
                .navigationTitle(Text(Constants.sourceGovUKTitle))
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

struct SourceView_Previews: PreviewProvider {
    static var previews: some View {
        SourceView()
    }
}
