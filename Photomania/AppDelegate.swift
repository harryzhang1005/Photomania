//
//  AppDelegate.swift
//  Photomania
//
//  Created by Harvey Zhang on 12/16/15.
//  Copyright © 2015 HappyGuy. All rights reserved.
//

import UIKit
import iAd

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // Override point for customization after application launch.
        
        // Set globally bars appearances
        UINavigationBar.appearance().barStyle = UIBarStyle.BlackTranslucent
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UIToolbar.appearance().barStyle = .BlackTranslucent
        
        UITabBar.appearance().barStyle = .Black
        UITabBar.appearance().translucent = true
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        
        UIButton.appearance().tintColor = UIColor.whiteColor()
        
        prepareForFullScreenAds() // Prepare to show full screen Ads
        
        return true
    }

    func prepareForFullScreenAds()
    {
        UIViewController.prepareInterstitialAds()
    }

}
