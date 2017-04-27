//
//  AppDelegate.swift
//  Songbook
//
//  Created by William Liddy on 2/23/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    // this runs when app starts. The only thing I need to do is copy the built-in songs to the user's document directory
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let fileManager = FileManager.default
        
        // collect all the resource files (the built in songs)
        var resourceFiles: [String] = []
        let resourcesPath = Bundle.main.resourcePath;
        do {
            resourceFiles = try fileManager.contentsOfDirectory(atPath: resourcesPath!)
        } catch {
            print(error)
        }
        
        // copy sample song files to user directory. Only send XMLs.
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        for file in resourceFiles
        {
            if((file as NSString).pathExtension != "xml")
            {
                continue
            }
            let destinationPath = documentDirectoryPath.appendingPathComponent(file)
            let sourcePath = resourcesPath! + "/" + file

            do
            {
                if(fileManager.fileExists(atPath: destinationPath))
                {
                    try fileManager.removeItem(atPath: destinationPath)
                }
                try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
            } catch
            {
               // should not error but have to catch- I know the path name is right
                print("Sample song copy error: \(error)")
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

}

