//
//  SongTableView.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/29/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import UIKit

class SongTableView: UITableView {
    
    override init(frame: CGRect, style: UITableViewStyle) {
        
        super.init(frame: frame, style: style)
        
        translatesAutoresizingMaskIntoConstraints = false
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = 74
        
        separatorColor = .darkGray
        backgroundColor = lightBlack
        scrollsToTop = true
        indicatorStyle = .white
        
        let nib = UINib(nibName: kSongCellId, bundle: nil)
        register(nib, forCellReuseIdentifier: kSongCellId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
