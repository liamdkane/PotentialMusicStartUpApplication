//
//  PotentialMusicStartUpApplicationTests.swift
//  PotentialMusicStartUpApplicationTests
//
//  Created by C4Q on 7/26/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import XCTest
@testable import PotentialMusicStartUpApplication

class PotentialMusicStartUpApplicationTests: XCTestCase {
    
    var requestManager: RequestManager!
    var testAlbums: [AlbumModel]!
    var testSongs: [SongModel]!

    override func setUp() {
        super.setUp()
        requestManager = RequestManager()
        testSongs = [SongModel(name: "A", trackNumber: 1, artists: ["A"], id: "1.1", albumId: "1"),
                     SongModel(name: "B", trackNumber: 2, artists: ["A"], id: "1.2", albumId: "1"),
                     SongModel(name: "C", trackNumber: 1, artists: ["B"], id: "2.1", albumId: "2"),
                     SongModel(name: "D", trackNumber: 1, artists: ["C"], id: "3.1", albumId: "3"),
                     SongModel(name: "E", trackNumber: 2, artists: ["C"], id: "3.2", albumId: "3")]
        testAlbums = [AlbumModel(name: "Hi", imageUrl: "www.thegame.com", id: "1"),
                      AlbumModel(name: "Hi2", imageUrl: "www.thegame2.com", id: "2"),
                      AlbumModel(name: "Hi3", imageUrl: "www.thegame3.com", id: "3")]
        requestManager.viewModel.songs = testSongs
        requestManager.viewModel.albums = testAlbums
    }
    
    override func tearDown() {
        requestManager = nil
        testAlbums = nil
        testSongs = nil
        super.tearDown()
    }
    
    func testModelCommunication() {
        let viewController = SongsTableViewController(viewModel: requestManager.viewModel)
        XCTAssert(viewController.songViewModel.albums == testAlbums)
    }
    
    func testFilter () {
        let filteredSongs = testSongs.filter{ $0.name == "Hi2" }
        requestManager.viewModel.filter(by: "Hi2", sort: .alphabetical)
        XCTAssert(filteredSongs == requestManager.viewModel.fileredAndSortedSongs)
    }
    
    func testAlbumSort () {
        let sortedSongs = testSongs.sorted { $0.albumId > $1.albumId }
        requestManager.viewModel.sort(by: .album)
        XCTAssert(sortedSongs == requestManager.viewModel.fileredAndSortedSongs)
    }
}

//This is just for testing.

extension AlbumModel: Equatable {
    
    public static func == (lhs: AlbumModel, rhs: AlbumModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension SongModel: Equatable {
    public static func == (lhs: SongModel, rhs: SongModel) -> Bool {
        return lhs.id == rhs.id
    }
}
