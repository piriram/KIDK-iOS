//
//  BaseCoordinator.swift
//  KIDK
//
//  Created by 잠만보김쥬디 on 11/14/25.
//

import UIKit
import RxSwift

class BaseCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        logLifecycle("init")
    }
    
    deinit {
        logLifecycle("deinit")
    }
    
    func start() {
        fatalError("start() must be overridden")
    }
    
    func removeAllChildCoordinators() {
        childCoordinators.removeAll()
        debugLog("All child coordinators removed")
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        debugLog("Child coordinator removed: \(String(describing: type(of: coordinator)))")
    }
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        debugLog("Child coordinator added: \(String(describing: type(of: coordinator)))")
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
