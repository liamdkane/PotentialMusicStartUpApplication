//
//  SongsTableViewController.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/28/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import UIKit
import SnapKit

enum Sort {
    case standard
    case alphabetical
    case byAlbum
}

class SongsTableViewController: UIViewController, UITableViewDelegate {
    
    let tableView = SongTableView(frame: .zero, style: .plain)
    let songViewModel: SongViewModel
    var sortPreference: Sort = .standard {
        didSet{
            songViewModel.sort(by: sortPreference)
        }
    }
    
    //Init with model data
    
    init(viewModel: SongViewModel) {
        self.songViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = []
    }
    
    //ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotification()
        configureTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterForNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureTableView () {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (tableView) in
            tableView.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
}
extension SongsTableViewController: UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if sortPreference == .byAlbum {
            return songViewModel.albums.count
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if sortPreference == .byAlbum {
            return songViewModel.fileredAndSortedSongs.filter {
                $0.albumId == songViewModel.albums[section].id
            }.count
        }

        return songViewModel.fileredAndSortedSongs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSongCellId, for: indexPath) as! SongTableViewCell
        var song: SongModel
        if sortPreference == .byAlbum {
            song = songViewModel.fileredAndSortedSongs
                .filter { $0.albumId == songViewModel.albums[indexPath.section].id
                }.sorted{ $0.trackNumber < $1.trackNumber}[indexPath.row]
        } else {
            song = songViewModel.fileredAndSortedSongs[indexPath.row]
        }
        
        configure(cell: cell, with: song)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sortPreference == .byAlbum {
            return songViewModel.albums[section].name
        }
        return nil

    }
    
    func configure(cell: SongTableViewCell, with song: SongModel) {
        //cell.albumImageView = songViewModel
        cell.songTitleLabel.text = song.name
        cell.artistsNamesLabel.text = song.artists.joined(separator: ", ")
    }

}

extension SongsTableViewController {
    //Notification Center Functions
    func registerForNotification () {
        //Because we are making ten different calls for the songs, I felt it was best to just send a notification of completion so that the table view could be updated accordingly
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(self, selector: #selector(handleSongNotification), name: kSongNotificationName, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleErrorNotification(_:)), name: kErrorNotificationName, object: Error.self)
    }
    
    func handleSongNotification() {
        self.tableView.reloadData()
    }
    
    func handleErrorNotification(_ note: Notification) {
        if let error = note.object as? Error {
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func unRegisterForNotification () {
        //If notifications aren't unregistered before leaving view, there is a crash.
        let noteCenter = NotificationCenter.default
        noteCenter.removeObserver(self)
    }

}
