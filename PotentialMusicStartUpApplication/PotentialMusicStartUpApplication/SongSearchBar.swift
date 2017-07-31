//
//  SongSearchBar.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/30/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import UIKit

class SongSearchBar: UISearchBar {

    var textView: UITextField? {
        if let subView = self.subviews.first {
            if let textField = subView.subviews.first(where: { $0 is UITextField }) as? UITextField {
                return textField
            }
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentMode = .left
        textView?.textColor = .white
        searchBarStyle = .minimal
        tintColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForFadeAnimation(fade: Bool) {
        if let textView = textView {
            textView.textColor = fade ? .clear : .white
            textView.subviews.forEach({ (view) in
                if let cancelButton = view as? UIButton {
                    cancelButton.imageView?.isHidden = fade
                }
            })
        }
        layoutIfNeeded()
    }
}
