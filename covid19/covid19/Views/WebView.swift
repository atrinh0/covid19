//
//  WebView.swift
//  covid19
//
//  Created by An Trinh on 27/02/2021.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL?
    let reload: Bool

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = url else { return }
        uiView.load(URLRequest(url: url))
    }
}
