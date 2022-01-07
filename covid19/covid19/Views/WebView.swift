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

    private let webView = WKWebView()

    func makeUIView(context: Context) -> WKWebView {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator,
                                 action: #selector(WebViewCoordinator.refreshWebView(_:)),
                                 for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true

        return webView
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(parent: self)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = url else { return }
        uiView.load(URLRequest(url: url))
    }

    func reloadWebView() {
        guard let url = url else { return }
        webView.load(URLRequest(url: url))
    }
}

class WebViewCoordinator: NSObject {
    var parent: WebView

    init(parent: WebView) {
        self.parent = parent
    }

    @objc func refreshWebView(_ sender: UIRefreshControl) {
        parent.reloadWebView()
        sender.endRefreshing()
    }
}
