//
//  BaseViewController.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import RxSwift
import SnapKit

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .kidkPink
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
        setupKeyboardDismiss()
        logLifecycle("viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logLifecycle("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logLifecycle("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logLifecycle("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logLifecycle("viewDidDisappear")
    }
    
    deinit {
        logLifecycle("deinit")
    }
    
    private func setupBaseUI() {
        view.backgroundColor = .kidkDarkBackground
        view.addSubview(loadingOverlay)
        loadingOverlay.addSubview(loadingIndicator)
        
        loadingOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showLoading() {
        loadingOverlay.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingOverlay.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func logLifecycle(_ method: String) {
        #if DEBUG
        debugLog("[\(String(describing: type(of: self)))] \(method)")
        #endif
    }
    
    func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("🐛 [\(fileName):\(line)] \(function) - \(message)")
        #endif
    }
    
    func debugSuccess(_ message: String) {
        #if DEBUG
        print("✅ \(message)")
        #endif
    }
    
    func debugError(_ message: String, error: Error? = nil) {
        #if DEBUG
        if let error = error {
            print("❌ \(message): \(error.localizedDescription)")
        } else {
            print("❌ \(message)")
        }
        #endif
    }
    
    func debugWarning(_ message: String) {
        #if DEBUG
        print("⚠️ \(message)")
        #endif
    }
}
