//
//  SongTableViewCell.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/29/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistsNamesLabel: UILabel!
    var song: SongModel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //Prevents 'flicker' when loading cells
    override func prepareForReuse() {
        self.albumImageView.image = nil
        self.songTitleLabel.text = nil
        self.artistsNamesLabel.text = nil
    }
    
}
