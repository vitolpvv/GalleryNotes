//
//  AppDelegate.swift
//  Notes
//
//  Created by VitalyP on 26/06/2019.
//  Copyright © 2019 vitalyp. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DDLog.add(DDTTYLogger.sharedInstance)
        
        // Раскоментировать, чтобы удалить токен из базы и запустить процесс авторизации заново
        UserDefaults().setValue(nil, forKey: "token")
        
        window = UIWindow()
        // Если токена нет в базе, запускает процесс аторизации. Иначе переходит на основной экран приложения
        switch UserDefaults().string(forKey: "token") {
        case .none:
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            vc?.persistentContainer = createPersistentContainer()
            window?.rootViewController = vc
        default:
            let tbc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? UITabBarController
            let nc = tbc?.selectedViewController as? UINavigationController
            let vc = nc?.topViewController as? NotesTableViewController
            vc?.persistentContainer = createPersistentContainer()
            window?.rootViewController = vc
        }
        return true
    }
    
    private func createPersistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "NotesModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }
}

