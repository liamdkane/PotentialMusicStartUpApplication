//
//  SongViewModel.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/28/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import Foundation
import Alamofire

struct SongModel {
    let name: String
    let trackNumber: Int
    let artists: [String]
    let id: String
    
}

struct AlbumModel {
    let name: String
    let imageUrl: String
    let id: String
}

class SongViewModel {
    var songs: [SongModel] = []
    var albums: [AlbumModel] = []
    var nextUrl: String = ""
    private var albumRequest: URLRequest? = nil
    private var songRequests: [URLRequest] = []
    private var imageRequests: [String: URLRequest] = [:]
    
    func getAlbums(callback: @escaping () -> Void) {
        Alamofire.request(albumRequest!).responseJSON { [weak self] (response) in
            //add in error handling
            
            if let validJson = response.result.value as? [String: Any] {
                self?.map(albumJson: validJson)
                callback()
            }
        }
    }
    
    func getSongs(callback: @escaping () -> Void) {
        _ = songRequests.map { request in
            Alamofire.request(request).responseJSON { [weak self] (response) in
                
                if let validJson = response.result.value as? [String: Any] {
                    let albumId = request.url!.deletingLastPathComponent().lastPathComponent
                    print(albumId)
                    self?.map(songJson: validJson)
                    callback()
                }
            }
        }
    }
    
    func map(songJson: [String: Any]) {
        if let songsArray = songJson[kItemsKey] as? [[String: Any]]{
            _ = songsArray.map{ songsDict in
                if let name = songsDict[kNameSongKey] as? String,
                    let artistDicts = songsDict[kArtistSongKey] as? [[String: Any]],
                    let trackNumber = songsDict[kTrackNumberSongKey] as? Int,
                    let id = songsDict[kIdSongKey] as? String {
                    
                    var artistNames = [String]()
                    _ = artistDicts.map {
                        if let name = $0[kNameSongKey] as? String {
                            artistNames.append(name)
                        }
                    }
                    
                    let song = SongModel(name: name, trackNumber: trackNumber, artists: artistNames, id: id)
                    songs.append(song)
                }
            }
        }
    }
    
    func map(albumJson: [String: Any]) {
        
        if let albumsDict = albumJson[kAlbumKey] as? [String: Any],
            let items = albumsDict[kItemsKey] as? [[String: Any]],
            let url = albumsDict[kNextUrlKey] as? String {
            
            self.nextUrl = url
            _ = items.map{ dict in
                if let id = dict[kAlbumIdKey] as? String,
                    let name = dict[kAlbumNameKey] as? String,
                    let imagesArray = dict[kImageDictionaryKey] as? [[String: Any]],
                    let thumbImageUrl = imagesArray.last?[kImageUrlKey] as? String {
                    
                    let album = AlbumModel(name: name, imageUrl: thumbImageUrl, id: id)
                    albums.append(album)
                    
                }
            }
        }
    }
    
    func add(imageRequest: URLRequest) {
        imageRequests[imageRequest.url!.absoluteString] = imageRequest
    }
    
    func add(songRequest: URLRequest) {
        songRequests.append(songRequest)
    }
    
    func set(request: URLRequest) {
        albumRequest = request
    }
}
