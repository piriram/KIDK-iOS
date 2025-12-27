import Foundation
import RxSwift
import RxCocoa

class BaseViewModel {
    
    let disposeBag = DisposeBag()
    
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishSubject<Error>()
    
    init() {
        logLifecycle("init")
    }
    
    deinit {
        logLifecycle("deinit")
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
    
    func startLoading() {
        isLoading.accept(true)
        debugLog("Loading started")
    }
    
    func stopLoading() {
        isLoading.accept(false)
        debugLog("Loading stopped")
    }
    
    func handleError(_ error: Error) {
        stopLoading()
        self.error.onNext(error)
        debugError("Error occurred", error: error)
    }
}
