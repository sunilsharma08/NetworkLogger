//
//  NLAuthenticationChallengeSender.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 04/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class NLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    typealias NLAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    fileprivate var handler: NLAuthenticationChallengeHandler
    
    init(handler: @escaping NLAuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        handler(URLSession.AuthChallengeDisposition.useCredential, credential)
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        handler(URLSession.AuthChallengeDisposition.useCredential, nil)
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        handler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        handler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        handler(URLSession.AuthChallengeDisposition.rejectProtectionSpace, nil)
    }
    
}

























