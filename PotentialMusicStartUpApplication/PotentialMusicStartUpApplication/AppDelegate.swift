//
//  AppDelegate.swift
//  PotentialMusicStartUpApplication
//
//  Created by C4Q on 7/26/17.
//  Copyright © 2017 Liam.Kane. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Maintaining a reference to the 
    var requestManager = RequestManager()

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        //This is a quick implementation of oauth, just redirecting the user to a browser is faster though less clean than WebKit
        
        if let sendingApp = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String {
            if sendingApp == "com.apple.mobilesafari" {
                    requestManager.requestToken(uri: url.absoluteString) {
                        self.requestManager.initialGetAllSongsFromNewReleases()
                }
            }
        }

        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.setUpNaviationAndTableVCs(viewModel: requestManager.viewModel)
        requestManager.requestAuthCode()
        return true
    }

    func setUpNaviationAndTableVCs(viewModel: SongViewModel) {
        
        //Create
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let tableVC = SongsTableViewController(viewModel: viewModel)
        let navVC = UINavigationController(rootViewController: tableVC)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }

}

