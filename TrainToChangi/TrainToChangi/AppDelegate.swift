//
//  AppDelegate.swift
//  TrainToChangi
//
//  Created by Zhi Yuan on 13/3/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import GoogleSignIn

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

        // Use Firebase library to configure APIs
        FIRApp.configure()

        initGoogleSignIn()

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

extension AppDelegate: GIDSignInDelegate {
    fileprivate func initGoogleSignIn() {
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {

        if let error = error {
            print(error.localizedDescription)
            return
        }

        // User signed into google

        // Get googleID token and google access token
        // and exchange for Firebase credential
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)

        AuthService.instance.login(credential: credential)
        // Segue away.
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
            -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                    annotation: [:])
        }
    }
}
