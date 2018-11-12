//
//  AppDelegate.swift
//  KeyprTestTask
//
//  Created by Borys Zinkovych on 11/8/18.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var weatherService: WeatherService?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataStack.sharedInstance.applicationDocumentsDirectory()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        weatherService = WeatherService(api: APIService())
        let mainVC = MainVC.create()
        let presenter = MainVCPresenter(weatherService: weatherService!, mainVC: mainVC)
        mainVC.presenter = presenter
        window?.rootViewController = UINavigationController(rootViewController: mainVC)
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(
            UIApplication.backgroundFetchIntervalMinimum)
        // Override point for customization after application launch.
        return true
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        weatherService!.fetchCompletion = completionHandler
        _ = weatherService!.loadWeatherIfRequired()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        _ = weatherService!.loadWeatherIfRequired()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.sharedInstance.saveContext()
    }
}

