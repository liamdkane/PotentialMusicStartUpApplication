//
//  DataManager.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/26/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import Foundation
import Alamofire

//Because of oauth, I wanted to manage the token seperately than the song requests, this necessitated an object to speak between the the token model and the song model.

class RequestManager {
    
    private let spotifyClientID = "92993bec8c7144fba4e201d272ffb402"
    private let spotifyClientSecret = "720c94216d1346cfbb865fa99e92076f"
    private let redirectUri = "PotentialMusicStartUpApplication://"
    private let spotifyAuthBaseUrl = "https://accounts.spotify.com/authorize"
    private let spotifyAccessTokenUrl = "https://accounts.spotify.com/api/token"
    private let newAlbumsUrl = "https://api.spotify.com/v1/browse/new-releases"
    private let songsForAlbumUrl = "https://api.spotify.com/v1/albums/*/tracks"
    
    private var authTokenManager = AuthTokenModel()
    var viewModel = SongViewModel()
    
    
    func display(error: Error) {
        print(error)
    }
    
    func requestAuth () {
        
        //This is the initial request/redirect to the Spotify page.
        //I chose to do this a little fast and loose, normally I believe creating another window/checking for the spotify app to be superior. There is an SDK to handle this situation, but it seemed unstable and in ObjectiveC which I don't need to introduce. Also I have enough dependencies.
        
        let itemDictionary = [
            "client_id" : spotifyClientID,
            "response_type" : "code",
            "redirect_uri" : redirectUri
        ]
        
        var authUrl = URLComponents(url: URL(string: spotifyAuthBaseUrl)!, resolvingAgainstBaseURL: true)
        authUrl?.queryItems = makeQueryItems(itemDictionary)
        UIApplication.shared.open(try! authUrl!.asURL(), options: [:], completionHandler: nil)
    }
    
    func requestToken(uri: String, callback: @escaping ()->Void) {
        
        let code = uri.components(separatedBy: "=").last!
        
        let codeDictionary = [
            "grant_type" : "authorization_code",
            "code" : code
        ]
        
        authTokenManager.set(urlRequest: generateTokenRequest(codeDictionary))
        authTokenManager.retrieveFromSpotify {
            callback()
        }
    }
    
    func refreshToken() {
        
        let refreshDictionary = [
            "grant_type" : kRefreshTokenKey,
            kRefreshTokenKey : self.authTokenManager.refreshToken
        ]
        
        authTokenManager.set(urlRequest: generateTokenRequest(refreshDictionary))
        authTokenManager.retrieveFromSpotify{}
    }
    
    func initialGetAllSongsFromNewReleases () {
        
        let request = generateNextAlbumRequest(url: newAlbumsUrl)
                
        self.viewModel.getAlbums(albumRequest: request) {
            let requests = self.viewModel.albums.map {
                self.generateSongRequest(id: $0.id)
            }
            self.viewModel.getSongs(songRequests: requests) {}
        }
    }
    
    
    //MARK: Helper Functions
    
    lazy var authHeader: HTTPHeaders = {
        let authHeaderString = "Bearer \(self.authTokenManager.accessToken)"
        let header = HTTPHeaders(dictionaryLiteral: ("Authorization", authHeaderString))
        return header
    }()
    
    private func generateSongRequest(id: String) -> URLRequest {
        let authHeaderString = "Bearer \(self.authTokenManager.accessToken)"
        let header = HTTPHeaders(dictionaryLiteral: ("Authorization", authHeaderString))
        
        let url = songsForAlbumUrl.replacingOccurrences(of: "*", with: id)
        let urlRequest = try! URLRequest(url: url, method: .get, headers: header)
        
        return urlRequest
    }
    
    private func generateNextAlbumRequest(url: String) -> URLRequest {
        let authHeaderString = "Bearer \(self.authTokenManager.accessToken)"
        let header = HTTPHeaders(dictionaryLiteral: ("Authorization", authHeaderString))
        
        let urlRequest = try! URLRequest(url: url, method: .get, headers: header)
        
        return urlRequest
    }
    
    
    private func generateTokenRequest(_ dictionary: [String: String]) -> URLRequest {
        
        var bodyDictionary = [
            "redirect_uri" : self.redirectUri,
            "client_id" : self.spotifyClientID,
            "client_secret" : self.spotifyClientSecret,
            ]
        
        dictionary.forEach {
            bodyDictionary[$0] = $1
        }
        
        let codeRequest = try! URLRequest(url: self.spotifyAccessTokenUrl, method: .post)
        let httpEncodedRequest = try! URLEncoding.default.encode(codeRequest, with: bodyDictionary)
        return httpEncodedRequest
    }
    
    
    private func makeQueryItems(_ dict: [String:String]) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        
        for item in dict {
            let item = URLQueryItem(name: item.key, value: item.value)
            queryItems.append(item)
        }
        return queryItems
    }
}
