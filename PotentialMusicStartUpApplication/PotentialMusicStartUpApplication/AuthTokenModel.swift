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
    //var httpAccessTokenRequest: URLRequest?
    
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
    
    //This was for the refresh cycle, the idea being that keys would be stored locally, every time a call would be made, expiration would be checked, and then refresh token would be handled. I decided that user defaults would be a good place to store this because it could potentially keep an API key over multiple launches of the app. I know that when I use a phone I constant quit an app, then check it again maybe 5-10 minutes later.
    func retrieveLocally() -> Bool {
        
        let defaults = UserDefaults.standard
        
        if let tokenDict = defaults.dictionary(forKey: kUserDefaultsKey){
            handle(tokenJson: tokenDict)
            return true
        }
        return false
        
    }
    
    
    func retrieveFromSpotify(httpAccessTokenRequest: URLRequest, callback: @escaping () -> Void) {
        
        Alamofire.request(httpAccessTokenRequest).responseJSON { [weak self] (response) in
            
            if let error = response.error {
                self?.handle(error)
            }
            
            if let validJson = response.result.value as? [String: AnyObject] {
                self?.handle(tokenJson: validJson)
                callback()
            }
            
        }
    }
    
    private func handle(tokenJson: [String: Any]) {
        
        if let accessToken = tokenJson[kAccessTokenKey] as? String,
            let refreshToken = tokenJson[kRefreshTokenKey] as? String,
            let timeUntilExpire = tokenJson[kExpireTimeKey] as? Int {
            let expireTime = Date(timeIntervalSinceNow: TimeInterval(timeUntilExpire))
            
            set(accessToken: accessToken, refreshToken: refreshToken, expireTime: expireTime)
        }
    }

    
//    func set(urlRequest: URLRequest) {
//        httpAccessTokenRequest = urlRequest
//    }
    
    func set(locally: Bool = false, accessToken access: String, refreshToken refresh: String, expireTime time: Date) {
        accessToken = access
        refreshToken = refresh
        expires = time
        if !locally {
            saveLocally()
        }
    }
}
