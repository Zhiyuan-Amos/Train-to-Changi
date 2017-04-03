//
//  AppDelegate.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storage: Storage = StorageManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // We retrieve the first view controller from the navigation
        // controller and pass to it the instance of StorageManager.
        guard let mapViewController = window?.rootViewController as? MapViewController else {
            fatalError("Root view controller not set correctly!")
        }
        mapViewController.storage = storage

        // Connect Firebase
        FIRApp.configure()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        storage.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        storage.save()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        storage.save()
    }

}
