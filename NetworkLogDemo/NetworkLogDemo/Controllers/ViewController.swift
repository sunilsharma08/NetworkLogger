//
//  ViewController.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import UIKit


enum RequestType {
    case url
    case urlRequest
}

class Model:Codable {
    var nname:String = "Hello"
}

class ViewController: UIViewController {
    
    var backgroundSession: URLSession? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
//        register()
        
//        overloadingTest(vari: OneProto())
//        overloadingTest(vari: TwoProto())
//        let testInstance = TestClass()
//        let selector = #selector((TestClass.overloadingTest(with:)) as (TestClass) -> (URL) -> Void)
//        let selector2 = #selector((TestClass.overloadingTest(with:)) as (TestClass) -> (URLRequest) -> Void)
//        perform(selector)
//        perform(selector2)
    }
    
    /**
     Print all environment variables key and value available.
     */
    func logEnvironmentVariables() {
        for (key, value) in ProcessInfo.processInfo.environment {
            print("\(key) => \(value)")
        }
    }
    
    func loadDataFromServer() {
        var urlRequest = URLRequest(url: URL(string: "https://gorest.co.in/public-api/users")!)
        urlRequest.addValue("Bearer ggolvSv4UpUH_a9Qk5x5KAC2YudbptpltVYZ", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .ephemeral)
        
//        let session = URLSession(configuration: .background(withIdentifier: "123"), delegate: self, delegateQueue: nil)
//        session.dataTask(with: urlRequest).resume()
        
        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Response \n \(String(describing: response))")
            } catch {
                print(error.localizedDescription)
            }
            print(urlResponse ?? "")
        }.resume()
    }
    
    func swizzleDataTask() {
        let instance = URLSession(configuration: .default)
        let urlSessionClass:AnyClass = object_getClass(instance)!
        let selector = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let fakeMethodSelector = #selector((URLSession.fakedataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        let originalMethod = class_getInstanceMethod(urlSessionClass, selector)!
        let fakeMethod = class_getInstanceMethod(URLSession.self, fakeMethodSelector)!
        method_exchangeImplementations(originalMethod, fakeMethod)
        
        let selector2 = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let fakeMethodSelector2 = #selector((URLSession.fakedataTasks(with:completionHandler:)) as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        let originalMethod2 = class_getInstanceMethod(urlSessionClass, selector2)!
        let fakeMethod2 = class_getInstanceMethod(URLSession.self, fakeMethodSelector2)!
        method_exchangeImplementations(originalMethod2, fakeMethod2)
        // Print stack trace
        //print("Stack trace \(Thread.callStackSymbols)")
        
    }
    
    @IBAction func clickedOnUrlRequest(_ sender: Any) {
        performNetworkTask(requestType: .urlRequest)
    }
    
    @IBAction func clickedOnNextButton(_ sender: Any) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        performNetworkTask(requestType: .url)
    }
    
    func register() {
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!
        
        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.fakeProcotolClasses))!
        
        method_exchangeImplementations(method1, method2)
        swizzleDataTask()
    }

}

private extension URLSession {
    @objc func fakedataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        print("Stack trace1 \(Thread.callStackSymbols)")
        print("Injected method 1")
//        let originalSession = self.fakedataTask(with: request, completionHandler: completionHandler)
        
        let originalSession = self.fakedataTask(with: request) { (data, response, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Intercepted response \(response ?? [:])")
            } catch {
                print(error.localizedDescription)
            }
            completionHandler(data,response,error)
        }
        return originalSession
    }
    
    @objc func fakedataTasks(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        print("Stack trace url \(Thread.callStackSymbols)")
        print("Injected method url")
        
        let originalSession = self.fakedataTasks(with: url) { (data, response, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Intercepted response url\(response ?? [:])")
            } catch {
                print(error.localizedDescription)
            }
            
            completionHandler(data,response,error)
        }
        return originalSession
    }
}

extension ViewController: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("Response -> \(String(describing: response.mimeType))")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
        backgroundSession?.finishTasksAndInvalidate()
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print(#function)
        backgroundSession?.finishTasksAndInvalidate()
    }
    
}

extension URLSessionConfiguration {
    
    @objc func fakeProcotolClasses() -> [AnyClass]? {
        guard let fakeProcotolClasses = self.fakeProcotolClasses() else {
            return []
        }
        var originalProtocolClasses = fakeProcotolClasses.filter {
            return $0 != CustomUrlProtocol.self
        }
        originalProtocolClasses.insert(CustomUrlProtocol.self, at: 0)
        return originalProtocolClasses
    }
    
}


extension ViewController {
    
    func performNetworkTask(requestType: RequestType) {
        switch requestType {
        case .url:
            loadDataUsingUrl()
            
        case .urlRequest:
            loadDataUsingUrlRequest()
        }
    }
    
    func loadDataUsingUrl() {
        print("============\(#function)============")
        let session = URLSession(configuration: .ephemeral)
        session.dataTask(with: URL(string: "https://gorest.co.in/public-api/users")!) { (data, urlResponse, error) in
//            print("Response \(#function) \n \(String(describing: urlResponse.debugDescription))")
            do {
                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
                print("Response JSON\(#function) \n \(String(describing: response))")
            } catch {
                print(error.localizedDescription)
            }
            }.resume()
    }
    
    func loadDataUsingUrlRequest() {
        print("============\(#function)============")
        var urlRequest = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
        urlRequest.addValue("Bearer ggolvSv4UpUH_a9Qk5x5KAC2YudbptpltVYZ", forHTTPHeaderField: "Authorization")
//        URLSession.shared.dataTask(with: urlRequest).resume()

//        let session = URLSession(configuration: .default)
//        session.dataTask(with: urlRequest) { (data, urlResponse, error) in
////            print("Response \(#function) \n \(String(describing: urlResponse))")
//            do {
//                let response = try JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any]
//                print("Response JSON \(#function) \n \(String(describing: response))")
//            } catch {
//                print(error.localizedDescription)
//            }
//            }.resume()
        
        let backgroundConf = URLSessionConfiguration.background(withIdentifier: "12345")
        self.backgroundSession = URLSession(configuration: backgroundConf, delegate: self, delegateQueue: nil)
        backgroundSession?.dataTask(with: urlRequest).resume()
        
    }
    
}

class CustomURLSession: URLSession {
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        print("Stack trace original \(Thread.callStackSymbols)")
        return super.dataTask(with: request, completionHandler: completionHandler)
    }
    
    override func fakedataTasks(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        print("Stack trace original url \(Thread.callStackSymbols)")
        return super.dataTask(with: url, completionHandler: completionHandler)
    }
    
}
