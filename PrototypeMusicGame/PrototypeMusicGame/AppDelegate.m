//
//  AppDelegate.m
//  Prototype1
//
//  Created by Joe Dakroub on 7/27/12.
//  Copyright (c) 2012 Joe Dakroub. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
{
    AVAudioSession *audioSession;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:NULL];
    [audioSession setActive:YES error:NULL];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [audioSession setActive:NO error:NULL];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [audioSession setActive:NO error:NULL];    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [audioSession setActive:YES error:NULL];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [audioSession setActive:YES error:NULL];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [audioSession setActive:NO error:NULL];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
