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
    let albumId: String
    
}

struct AlbumModel {
    let name: String
    let imageUrl: String
    let id: String
}

class SongViewModel: ErrorHandler {
    var albums: [AlbumModel] = []
    var nextUrl: String = ""
    private var imageDataCache = [String: Data]()
    private var currentTasks = Set<String>()
    
    var songs: [SongModel] = [] {
        didSet {
            fileredAndSortedSongs = songs
        }
    }
    
    var fileredAndSortedSongs: [SongModel] = [] {
        didSet {
            let noteCenter = NotificationCenter.default
            noteCenter.post(name: kSongNotificationName, object: nil)
        }
    }
    
    //These are the two API calls to get the albums and songs respectively
    func getAlbums(albumRequest: URLRequest, callback: @escaping () -> Void) {
        Alamofire.request(albumRequest).responseJSON { [weak self] (response) in
            
            if let error = response.error {
                self?.handle(error)
            }
            
            if let validJson = response.result.value as? [String: Any] {
                self?.map(albumJson: validJson)
                callback()
            }
        }
    }
    
    func getSongs(songRequests: [URLRequest], callback: @escaping () -> Void) {
        songRequests.forEach { request in
            Alamofire.request(request).responseJSON { [weak self] (response) in
                
                if let error = response.error {
                    self?.handle(error)
                }
                
                if let validJson = response.result.value as? [String: Any] {
                    //the way the URL is written, the second to last component is the albumID
                    let albumId = request.url!.deletingLastPathComponent().lastPathComponent
                    self?.map(albumId: albumId, songJson: validJson)
                    callback()
                }
            }
        }
    }
    
    //This is getting each image, checking to see if the task has already been completed or is being worked on before calling the API
    func getImage(for song: SongModel, callback: @escaping (Data?) -> Void) {
        let album = albums.first{ $0.id == song.albumId }!
        
        if let data = imageDataCache[album.imageUrl] {
            callback(data)
            
            return
        } else if currentTasks.insert(album.imageUrl).inserted {
            Alamofire.request(album.imageUrl).response { [weak self] (response) in
                self?.currentTasks.remove(album.imageUrl)
                
                if let error = response.error {
                    self?.handle(error)
                }
                
                if let data = response.data {
                    self?.imageDataCache[album.imageUrl] = data
                    let noteCenter = NotificationCenter.default
                    noteCenter.post(name: kImageNotificationName, object: album.id)
                }
            }
        } 
    }
    
    func sort(by: Sort) {
        switch by {
        case .alphabetical:
            fileredAndSortedSongs = songs.sorted{ $0.name < $1.name }
        case .album:
            fileredAndSortedSongs = songs.sorted{ $0.albumId > $1.albumId }
        case .standard:
            fileredAndSortedSongs = songs
        }
    }
    
    func filter(by term: String, sort: Sort) {
        self.sort(by: sort)
        fileredAndSortedSongs = fileredAndSortedSongs.filter {
            $0.name.hasPrefix(term)
        }
    }
    
    
    private func map(albumId: String, songJson: [String: Any]) {
        
        if let songsArray = songJson[kItemsKey] as? [[String: Any]] {
            let songsInAlbum: [SongModel] = songsArray.flatMap { songsDict in
                if let name = songsDict[kNameSongKey] as? String,
                    let artistDicts = songsDict[kArtistSongKey] as? [[String: Any]],
                    let trackNumber = songsDict[kTrackNumberSongKey] as? Int,
                    let id = songsDict[kIdSongKey] as? String {
                    let artistNames: [String] = artistDicts.flatMap {
                        return $0[kNameSongKey] as? String
                    }
                    
                    let song = SongModel(name: name, trackNumber: trackNumber, artists: artistNames, id: id, albumId: albumId)
                    return song
                } else {
                    return nil
                }
            }
            songs += songsInAlbum
        }
    }
    
    private func map(albumJson: [String: Any]) {
        
        if let albumsDict = albumJson[kAlbumKey] as? [String: Any],
            let items = albumsDict[kItemsKey] as? [[String: Any]],
            let url = albumsDict[kNextUrlKey] as? String {
            
            self.nextUrl = url
            items.forEach { dict in
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
    
    private func handle(_ error: Error) {
        let noteCenter = NotificationCenter.default
        noteCenter.post(name: kErrorNotificationName, object: error)
    }
}
