//
//  BridgeDemoViewController.swift
//  xxf_ios
//
//  Created by xxf on 5/13.
//

#if canImport(UIKit)
import Foundation
import UIKit

public final class BridgeDemoViewController: UIViewController {
    private struct NativeToWebRequestData: Codable {
        let text: String
        let timestamp: String
    }

    private struct NativeToWebResponseData: Codable {
        let echo: String
        let receivedAt: String
    }

    private struct WebToNativeRequestData: Codable {
        let text: String
    }

    private struct WebToNativeResponseData: Codable {
        let reply: String
        let receivedAt: String
    }

    private let bridgeWebView = BridgeWebView()

    private let nativeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Native Bridge Demo"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let nativeStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Native 收到的 H5 消息：-"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private let nativeResultLabel: UILabel = {
        let label = UILabel()
        label.text = "Native 发送到 H5 的回包：-"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private let nativeInputField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "输入 native -> H5 的消息"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        return textField
    }()

    private lazy var nativeSendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send To H5", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleNativeSendButtonTapped), for: .touchUpInside)
        return button
    }()

    private let nativePanel: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let webPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let nativeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private let webHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "H5 Bridge Demo"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let webStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "H5 收到的 native 消息：-"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private let webBridgeInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Web 侧通过 `bridge.call('handleWebEvent', ...)` 发送消息给 native。"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()

    public override func loadView() {
        view = UIView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Bridge Demo"
        setupLayout()
        setupWebBridge()
        loadDemoPage()
    }

    private func setupLayout() {
        view.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false

        containerStackView.addArrangedSubview(nativePanel)
        containerStackView.addArrangedSubview(webPanel)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        setupNativePanel()
        setupWebPanel()
    }

    private func setupNativePanel() {
        nativePanel.addSubview(nativeStackView)
        nativeStackView.translatesAutoresizingMaskIntoConstraints = false

        nativeStackView.addArrangedSubview(nativeTitleLabel)
        nativeStackView.addArrangedSubview(nativeStatusLabel)
        nativeStackView.addArrangedSubview(nativeResultLabel)
        nativeStackView.addArrangedSubview(nativeInputField)
        nativeStackView.addArrangedSubview(nativeSendButton)

        NSLayoutConstraint.activate([
            nativeStackView.topAnchor.constraint(equalTo: nativePanel.topAnchor, constant: 16),
            nativeStackView.leadingAnchor.constraint(equalTo: nativePanel.leadingAnchor, constant: 16),
            nativeStackView.trailingAnchor.constraint(equalTo: nativePanel.trailingAnchor, constant: -16),
            nativeStackView.bottomAnchor.constraint(lessThanOrEqualTo: nativePanel.bottomAnchor, constant: -16)
        ])
    }

    private func setupWebPanel() {
        webPanel.addSubview(webHeaderLabel)
        webPanel.addSubview(webStatusLabel)
        webPanel.addSubview(webBridgeInfoLabel)
        webPanel.addSubview(bridgeWebView)

        webHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        webStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        webBridgeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        bridgeWebView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webHeaderLabel.topAnchor.constraint(equalTo: webPanel.topAnchor, constant: 16),
            webHeaderLabel.leadingAnchor.constraint(equalTo: webPanel.leadingAnchor, constant: 16),
            webHeaderLabel.trailingAnchor.constraint(equalTo: webPanel.trailingAnchor, constant: -16),

            webStatusLabel.topAnchor.constraint(equalTo: webHeaderLabel.bottomAnchor, constant: 8),
            webStatusLabel.leadingAnchor.constraint(equalTo: webPanel.leadingAnchor, constant: 16),
            webStatusLabel.trailingAnchor.constraint(equalTo: webPanel.trailingAnchor, constant: -16),

            webBridgeInfoLabel.topAnchor.constraint(equalTo: webStatusLabel.bottomAnchor, constant: 8),
            webBridgeInfoLabel.leadingAnchor.constraint(equalTo: webPanel.leadingAnchor, constant: 16),
            webBridgeInfoLabel.trailingAnchor.constraint(equalTo: webPanel.trailingAnchor, constant: -16),

            bridgeWebView.topAnchor.constraint(equalTo: webBridgeInfoLabel.bottomAnchor, constant: 12),
            bridgeWebView.leadingAnchor.constraint(equalTo: webPanel.leadingAnchor),
            bridgeWebView.trailingAnchor.constraint(equalTo: webPanel.trailingAnchor),
            bridgeWebView.bottomAnchor.constraint(equalTo: webPanel.bottomAnchor),
        ])
    }

    private func setupWebBridge() {
        bridgeWebView.onWebEvent = { [weak self] request, callback in
            guard let self else { return }

            let messageText = Self.stringValue(from: request.data.value)
            self.webStatusLabel.text = "H5 收到的 native 消息：\(request.event) | \(messageText)"

            callback(.init(
                code: 0,
                message: "native received",
                data: .init([
                    "reply": "native got your message",
                    "receivedAt": Self.timestampString()
                ])
            ))
        }
    }

    private func loadDemoPage() {
        bridgeWebView.loadHTMLString(Self.makeHTML(), baseURL: nil)
    }

    @objc
    private func handleNativeSendButtonTapped() {
        let text = nativeInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else {
            nativeResultLabel.text = "Native 发送到 H5 的回包：请先输入内容"
            return
        }

        nativeResultLabel.text = "Native 发送到 H5 的回包：sending..."

        let request = WebEventRequest(
            event: "nativeMessage",
            data: NativeToWebRequestData(
                text: text,
                timestamp: Self.timestampString()
            )
        )

        bridgeWebView.postEvent(
            request,
            expecting: WebEventResponse<NativeToWebResponseData>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .success(let response):
                    self.nativeResultLabel.text =
                        "Native 发送到 H5 的回包：code=\(response.code), message=\(response.message ?? "-"), data=\(response.data.echo) @ \(response.data.receivedAt)"
                case .failure(let error):
                    self.nativeResultLabel.text = "Native 发送到 H5 的回包：error=\(error.localizedDescription)"
                }
            }
        }
    }

    private static func makeHTML() -> String {
        """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
          <style>
            :root {
              color-scheme: light;
              --bg: #0f172a;
              --card: #111827;
              --card2: #1f2937;
              --text: #e5e7eb;
              --muted: #94a3b8;
              --accent: #38bdf8;
              --accent2: #22c55e;
              --border: rgba(148, 163, 184, 0.18);
            }
            * { box-sizing: border-box; }
            html, body {
              margin: 0;
              padding: 0;
              min-height: 100%;
              background:
                radial-gradient(circle at top left, rgba(56, 189, 248, 0.16), transparent 35%),
                radial-gradient(circle at bottom right, rgba(34, 197, 94, 0.12), transparent 30%),
                var(--bg);
              color: var(--text);
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            }
            body {
              padding: 16px;
            }
            .card {
              background: linear-gradient(180deg, rgba(17, 24, 39, 0.96), rgba(31, 41, 55, 0.94));
              border: 1px solid var(--border);
              border-radius: 18px;
              padding: 16px;
              box-shadow: 0 20px 50px rgba(0, 0, 0, 0.24);
            }
            .title {
              font-size: 20px;
              font-weight: 700;
              margin-bottom: 6px;
            }
            .desc {
              color: var(--muted);
              font-size: 13px;
              line-height: 1.45;
              margin-bottom: 14px;
            }
            .result, .log {
              background: rgba(15, 23, 42, 0.75);
              border: 1px solid var(--border);
              border-radius: 14px;
              padding: 12px;
              min-height: 72px;
              font-size: 13px;
              line-height: 1.5;
              white-space: pre-wrap;
              word-break: break-word;
            }
            .section-title {
              margin: 14px 0 8px;
              font-size: 12px;
              text-transform: uppercase;
              letter-spacing: 0.08em;
              color: var(--muted);
            }
            .row {
              display: flex;
              gap: 8px;
              margin-top: 12px;
            }
            input {
              flex: 1;
              min-width: 0;
              border: 1px solid var(--border);
              border-radius: 12px;
              padding: 12px 14px;
              outline: none;
              color: var(--text);
              background: rgba(15, 23, 42, 0.9);
              font-size: 14px;
            }
            button {
              border: 0;
              border-radius: 12px;
              padding: 0 16px;
              background: linear-gradient(135deg, var(--accent), var(--accent2));
              color: #00111a;
              font-weight: 700;
              cursor: pointer;
              min-width: 92px;
            }
            button:active { transform: translateY(1px); }
          </style>
        </head>
        <body>
          <div class="card">
            <div class="title">H5 Bridge Demo</div>
            <div class="desc">
              上面 native 会推消息进来，下面可以主动发送消息给 native。
              两个方向都走 DSBridge。
            </div>

            <div class="section-title">Native -> H5 Result</div>
            <div id="nativeResult" class="result">等待 native 推送...</div>

            <div class="section-title">Send H5 -> Native</div>
            <div class="row">
              <input id="messageInput" type="text" placeholder="输入要发给 native 的内容" />
              <button id="sendButton" type="button">Send</button>
            </div>

            <div class="section-title">H5 -> Native Result</div>
            <div id="nativeReply" class="log">等待发送...</div>
          </div>

          <script src="https://cdn.jsdelivr.net/npm/dsbridge@3.1.4/dist/dsbridge.js"></script>
          <script>
        \(Self.bridgeBootstrapScript())
          </script>

          <script>
            (function () {
              const nativeResult = document.getElementById('nativeResult')
              const nativeReply = document.getElementById('nativeReply')
              const input = document.getElementById('messageInput')
              const button = document.getElementById('sendButton')

              function render(obj) {
                try {
                  return JSON.stringify(obj, null, 2)
                } catch (e) {
                  return String(obj)
                }
              }

              // native -> h5
              dsBridge.registerAsyn('nativeEvent', function(request, callback) {
                nativeResult.textContent = render(request)
                callback({
                  code: 0,
                  message: 'h5 received',
                  data: {
                    echo: request.data.text,
                    receivedAt: new Date().toISOString()
                  }
                })
              })

              // h5 -> native
              button.addEventListener('click', function () {
                const text = input.value.trim()
                if (!text) {
                  nativeReply.textContent = '请输入内容'
                  return
                }

                const request = {
                  event: 'webMessage',
                  data: {
                    text: text
                  }
                }

                nativeReply.textContent = 'sending...\\n' + render(request)

                bridge.call('handleWebEvent', request, function(response) {
                  nativeReply.textContent = render(response)
                })
              })
            })()
          </script>
        </body>
        </html>
        """
    }

    private static func bridgeBootstrapScript() -> String {
        """
        var bridge = {
            default:this,// for typescript
            call: function (method, args, cb) {
                var ret = '';
                if (typeof args == 'function') {
                    cb = args;
                    args = {};
                }
                var arg={data:args===undefined?null:args}
                if (typeof cb == 'function') {
                    var cbName = 'dscb' + window.dscb++;
                    window[cbName] = cb;
                    arg['_dscbstub'] = cbName;
                }
                arg = JSON.stringify(arg)

                if(window._dsbridge){
                   ret=  _dsbridge.call(method, arg)
                }else if(window._dswk||navigator.userAgent.indexOf("_dsbridge")!=-1){
                   ret = prompt("_dsbridge=" + method, arg);
                }

               return  JSON.parse(ret||'{}').data
            },
            register: function (name, fun, asyn) {
                var q = asyn ? window._dsaf : window._dsf
                if (!window._dsInit) {
                    window._dsInit = true;
                    setTimeout(function () {
                        bridge.call("_dsb.dsinit");
                    }, 0)
                }
                if (typeof fun == "object") {
                    q._obs[name] = fun;
                } else {
                    q[name] = fun
                }
            },
            registerAsyn: function (name, fun) {
                this.register(name, fun, true);
            },
            hasNativeMethod: function (name, type) {
                return this.call("_dsb.hasNativeMethod", {name: name, type:type||"all"});
            },
            disableJavascriptDialogBlock: function (disable) {
                this.call("_dsb.disableJavascriptDialogBlock", {
                    disable: disable !== false
                })
            }
        };

        !function () {
            if (window._dsf) return;
            var ob = {
                _dsf: {
                    _obs: {}
                },
                _dsaf: {
                    _obs: {}
                },
                dscb: 0,
                dsBridge: bridge,
                close: function () {
                    bridge.call("_dsb.closePage")
                },
                _handleMessageFromNative: function (info) {
                    var arg = JSON.parse(info.data);
                    var ret = {
                        id: info.callbackId,
                        complete: true
                    }
                    var f = this._dsf[info.method];
                    var af = this._dsaf[info.method]
                    var callSyn = function (f, ob) {
                        ret.data = f.apply(ob, arg)
                        bridge.call("_dsb.returnValue", ret)
                    }
                    var callAsyn = function (f, ob) {
                        arg.push(function (data, complete) {
                            ret.data = data;
                            ret.complete = complete!==false;
                            bridge.call("_dsb.returnValue", ret)
                        })
                        f.apply(ob, arg)
                    }
                    if (f) {
                        callSyn(f, this._dsf);
                    } else if (af) {
                        callAsyn(af, this._dsaf);
                    } else {
                        var name = info.method.split('.');
                        if (name.length<2) return;
                        var method=name.pop();
                        var namespace=name.join('.')
                        var obs = this._dsf._obs;
                        var ob = obs[namespace] || {};
                        var m = ob[method];
                        if (m && typeof m == "function") {
                            callSyn(m, ob);
                            return;
                        }
                        obs = this._dsaf._obs;
                        ob = obs[namespace] || {};
                        m = ob[method];
                        if (m && typeof m == "function") {
                            callAsyn(m, ob);
                            return;
                        }
                    }
                }
            };
            window._dsf = ob._dsf;
            window._dsaf = ob._dsaf;
            window.dscb = ob.dscb;
            window.dsBridge = bridge;
            window._handleMessageFromNative = ob._handleMessageFromNative;
        }();
        """
    }

    private static func timestampString() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: Date())
    }

    private static func stringValue(from value: Any) -> String {
        if let string = value as? String {
            return string
        }
        if JSONSerialization.isValidJSONObject(value),
           let data = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return String(describing: value)
    }
}

#endif
