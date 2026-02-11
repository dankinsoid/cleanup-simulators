import SwiftUI
import WebKit

struct PaymentWebView: NSViewRepresentable {
    let url: URL
    var onReturnURL: (() -> Void)?

    private static let returnHost = "localhost"
    private static let returnPath = "/payment-callback"

    /// The return URL that TBC should redirect to after payment.
    static var returnURL: String {
        "https://\(returnHost)\(returnPath)"
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onReturnURL: onReturnURL)
    }

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_: WKWebView, context _: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onReturnURL: (() -> Void)?

        init(onReturnURL: (() -> Void)?) {
            self.onReturnURL = onReturnURL
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url,
               url.host == PaymentWebView.returnHost,
               url.path == PaymentWebView.returnPath
            {
                decisionHandler(.cancel)
                onReturnURL?()
                return
            }
            decisionHandler(.allow)
        }
    }
}
