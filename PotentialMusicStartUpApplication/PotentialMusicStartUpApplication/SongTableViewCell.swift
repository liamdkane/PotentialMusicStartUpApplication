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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
