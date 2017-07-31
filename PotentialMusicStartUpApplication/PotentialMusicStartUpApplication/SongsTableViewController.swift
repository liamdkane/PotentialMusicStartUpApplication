//
//  SongsTableViewController.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/28/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import UIKit
import SnapKit

enum Sort: String {
    case standard
    case alphabetical
    case album
    
    static func ordered() -> [Sort] {
        return [.standard, .alphabetical, .album]
    }
    
    static func orderedStrings() -> [String] {
        return ordered().map { return $0.rawValue.capitalized }
    }
}

//Universal Colours
let lightBlack = UIColor(white: 0.185, alpha: 0.8)



class SongsTableViewController: UIViewController, UITableViewDelegate {
    
    let tableView = SongTableView(frame: .zero, style: .plain)
    let songViewModel: SongViewModel
    var sortPreference: Sort = .standard {
        didSet{
            songViewModel.filter(by: searchBar.text ?? "", sort: sortPreference)
        }
    }
    
    var searchButton: UIBarButtonItem!
    var menuButton: UIBarButtonItem!
    var searchBar: SongSearchBar!
    var sortControl: UISegmentedControl!
    var menuDisplaying = false
    
    
    //Init with model data
    
    init(viewModel: SongViewModel) {
        self.songViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = []
    }
    
    //ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightBlack
        registerForNotification()
        configureTableView()
        configureNavigationBar()
        configureSortControl()
        configureGesture()
        makeStartingConstraints()
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
    }
    
    func configureNavigationBar () {
        
        let navBar = navigationController?.navigationBar
        
        let fontAttributes: [String: Any] = [NSForegroundColorAttributeName: UIColor.white,
                              NSFontAttributeName: UIFont(name: kFontName, size: 21)!]
        navBar?.titleTextAttributes = fontAttributes
        navBar?.barTintColor = lightBlack
        
        toggleTitle(on: true)
        
        menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(menuButtonPressed))
        menuButton.tintColor = .white
        navigationItem.rightBarButtonItem = menuButton
        
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonPressed))
        searchButton.tintColor = .white
        navigationItem.leftBarButtonItem = searchButton
        
        //This is initialized with frame/injected into the navigation bar as a minor hack. I don't believe you can set the left button item to a search bar, so I decided to hide the button, and inject the searchBar. I didn't use constraints because of the uncertainty of how they could conflict with the other views.
        searchBar = SongSearchBar(frame: CGRect(x: 12, y:  0, width: 60, height: 44.0))
        navBar?.addSubview(searchBar)
        searchBar.isHidden = true
        searchBar.delegate = self
    }
    
    func toggleTitle(on: Bool) {
        navigationItem.title = on ? kTitle : ""
    }
        
    @objc private func searchButtonPressed() {
        showSearchBar()
    }
    
    func menuButtonPressed () {
        menuDisplaying = !menuDisplaying
        switch menuDisplaying {
        case true:
            menuButton.image = #imageLiteral(resourceName: "close")
        case false:
            menuButton.image = #imageLiteral(resourceName: "menu")
        }
        animateSortControl()
    }
    
    func configureSortControl () {
        sortControl = UISegmentedControl(items: Sort.orderedStrings())
        let font = UIFont(name: kFontName, size: 17)
        sortControl.setTitleTextAttributes([NSFontAttributeName: font!], for: .normal)
        
        sortControl.addTarget(self, action: #selector(sortChanged(_:)), for: .valueChanged)
        view.addSubview(sortControl)
        sortControl.selectedSegmentIndex = 0
        
        //Shout out to Stationhead
        sortControl.backgroundColor = lightBlack
        sortControl.tintColor = .red
        
        
    }
    
    func makeStartingConstraints() {
        sortControl.snp.remakeConstraints { (view) in
            view.bottom.equalTo(self.view.snp.top).offset(-self.navigationController!.navigationBar.frame.height)
            view.leading.trailing.equalToSuperview()
        }
        tableView.snp.remakeConstraints { (view) in
            view.top.trailing.leading.bottom.equalToSuperview()
        }
    }
    
    func animateSortControl () {
        switch menuDisplaying {
        case true:
            sortControl.snp.remakeConstraints { (view) in
                view.leading.trailing.top.equalToSuperview()
            }
            tableView.snp.remakeConstraints({ (view) in
                view.top.equalTo(sortControl.snp.bottom)
                view.trailing.leading.bottom.equalToSuperview()
            })
        case false:
            sortControl.snp.remakeConstraints { (view) in
                view.bottom.equalTo(self.view.snp.top).offset(-self.navigationController!.navigationBar.frame.height)
                view.leading.trailing.equalToSuperview()
            }
            tableView.snp.remakeConstraints { (view) in
                view.top.trailing.leading.bottom.equalToSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func sortChanged(_ sender: UISegmentedControl) {
        sortPreference = Sort.ordered()[sender.selectedSegmentIndex]
    }
    
}

extension SongsTableViewController: UISearchBarDelegate {
    
    func showSearchBar() {
        searchBar.isHidden = false
        toggleTitle(on: false)
        navigationItem.setLeftBarButton(nil, animated: false)
        self.searchBar.prepareForFadeAnimation(fade: false)
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.05, options: [], animations: {
            let desiredWidth = UIScreen.main.bounds.width - self.menuButton.image!.size.width - 42
            self.adjustSearchBar(width: desiredWidth)

            self.searchBar.layoutIfNeeded()
        }) { (finished) in
            self.searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearchBar() {
        searchBar.prepareForFadeAnimation(fade: true)
        searchBar.textView?.endFloatingCursor()

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [], animations: {
            self.adjustSearchBar(width: 60)
        }, completion: { finished in
            self.searchBar.isHidden = true
            self.searchBar.resignFirstResponder()
            self.navigationItem.setLeftBarButton(self.searchButton, animated: false)
            self.toggleTitle(on: true)
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        songViewModel.filter(by: searchText, sort: sortPreference)
    }
    
    private func adjustSearchBar(width: CGFloat) {
        self.searchBar.frame = CGRect(x: self.searchBar.frame.origin.x,
                                      y: self.searchBar.frame.origin.y,
                                      width: width,
                                      height: self.searchBar.frame.height)
        self.searchBar.layoutIfNeeded()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearchBar()
    }
}

extension SongsTableViewController: UITableViewDataSource {
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if sortPreference == .album {
            return songViewModel.albums.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if sortPreference == .album {
            return countAlbums(in: section)
        }
        
        return songViewModel.fileredAndSortedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSongCellId, for: indexPath) as! SongTableViewCell
        var song: SongModel
        if sortPreference == .album {
            song = songViewModel.fileredAndSortedSongs
                .filter { $0.albumId == songViewModel.albums[indexPath.section].id
                }.sorted{ $0.trackNumber < $1.trackNumber}[indexPath.row]
        } else {
            song = songViewModel.fileredAndSortedSongs[indexPath.row]
        }
        
        configure(cell: cell, with: song)
        return cell
    }
    
    func configure(cell: SongTableViewCell, with song: SongModel) {
        self.songViewModel.getImage(for: song) { (data) in
            if let data = data,
                let image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    cell.albumImageView.image = image
                    cell.setNeedsLayout()
                }
            }
        }
        cell.song = song
        cell.songTitleLabel.text = song.name
        cell.artistsNamesLabel.text = song.artists.joined(separator: ", ")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont(name: kFontName, size: 19.0)
            headerView.textLabel?.textColor = .white
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sortPreference == .album,
            countAlbums(in: section) > 0 {
            return songViewModel.albums[section].name
        }
        return nil
    }
    
    private func countAlbums(in section: Int) -> Int {
        return songViewModel.fileredAndSortedSongs.filter {
            $0.albumId == songViewModel.albums[section].id
            }.count
    }
}

extension SongsTableViewController {
    //Notification Center Functions
    func registerForNotification () {
        //Because we are making ten different calls for the songs, I felt it was best to just send a notification of completion so that the table view could be updated accordingly
        let noteCenter = NotificationCenter.default
        noteCenter.addObserver(self, selector: #selector(handleSongNotification), name: kSongNotificationName, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleImageNotification(_:)), name: kImageNotificationName, object: nil)
        noteCenter.addObserver(self, selector: #selector(handleErrorNotification(_:)), name: kErrorNotificationName, object: Error.self)
    }
    
    func handleSongNotification() {
        tableView.reloadData()
    }
    
    func handleImageNotification(_ note: Notification) {
        if let albumId = note.object as? String {
            tableView.visibleCells.forEach({ (cell) in
                if let songCell = cell as? SongTableViewCell,
                    songCell.song.albumId == albumId {
                    configure(cell: songCell, with: songCell.song)
                }
            })
        }
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

extension SongsTableViewController: UIGestureRecognizerDelegate {
    
    func configureGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
    }
    
    func handle(tap: UITapGestureRecognizer) {
        hideSearchBar()
    }
}
