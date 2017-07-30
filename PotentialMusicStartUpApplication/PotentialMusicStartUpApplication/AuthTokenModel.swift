//
//  AuthTokenModel.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/27/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//


import Foundation
import Alamofire

class AuthTokenModel: ErrorHandler {
    
    var accessToken = ""
    var refreshToken = ""
    var expires = Date()
    var httpAccessTokenRequest: URLRequest?
    
    var isValidToken: Bool {
        return expires < Date()
    }
    func saveLocally() {
        let defaults = UserDefaults.standard
        let tokenDict: [String: Any] = [
            kAccessTokenKey : self.accessToken,
            kRefreshTokenKey : self.refreshToken,
            kExpireTimeKey : self.expires
        ]
        
        defaults.set(tokenDict, forKey: kUserDefaultsKey)
    }
    
    
    func retrieveLocally() -> Bool {
        
        let defaults = UserDefaults.standard
        
        if let tokenDict = defaults.dictionary(forKey: kUserDefaultsKey){
            handle(tokenJson: tokenDict)
            return true
        }
        return false
        
    }
    
    
    //todo: add in error handling
    func retrieveFromSpotify(callback: @escaping () -> Void) {
        
        Alamofire.request(self.httpAccessTokenRequest!).responseJSON { [weak self] (response) in
            
            if let error = response.error {
                self?.handle(error)
            }
            
            if let validJson = response.result.value as? [String: AnyObject] {
                self?.handle(tokenJson: validJson)
                callback()
            }
            
        }
    }
    
    //var valid
    
    private func handle(tokenJson: [String: Any]) {
        
        if let accessToken = tokenJson[kAccessTokenKey] as? String,
            let refreshToken = tokenJson[kRefreshTokenKey] as? String,
            let timeUntilExpire = tokenJson[kExpireTimeKey] as? Int {
            let expireTime = Date(timeIntervalSinceNow: TimeInterval(timeUntilExpire))
            
            set(accessToken: accessToken, refreshToken: refreshToken, expireTime: expireTime)
        }
    }

    
    func set(urlRequest: URLRequest) {
        httpAccessTokenRequest = urlRequest
    }
    
    func set(locally: Bool = false, accessToken access: String, refreshToken refresh: String, expireTime time: Date) {
        accessToken = access
        refreshToken = refresh
        expires = time
        if !locally {
            saveLocally()
        }
    }
}
