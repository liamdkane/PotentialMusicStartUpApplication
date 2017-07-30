//
//  ErrorHandler.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/30/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import Foundation

protocol ErrorHandler {
    //Intentionally Blank
}

extension ErrorHandler {
    func handle(_ error: Error) {
        let noteCenter = NotificationCenter.default
        noteCenter.post(name: kErrorNotificationName, object: error)
    }
}
