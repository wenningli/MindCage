//
//  AppDelegate.m
//  SimpleControl
//
//  Created by Cheong on 6/11/12.
//  Copyright (c) 2012 RedBearLab. All rights reserved.
//

#import "TGAccessoryManager.h"
#import "TableViewController.h"
#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"initializtu");
    //
    // to use a connection to the ThinkGear Connector for
    // Simulated Data, uncomment the next line
    //accessoryType = TGAccessoryTypeSimulated;
    //
    // NOTE: this wont do anything to get the simulated data stream
    // started. See the ThinkGear Connector Guide.
    //
     /*
    if(rawEnabled) {
        // setup the TGAccessoryManager to dispatch dataReceived notifications every 0.05s (20 times per second)
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.05 forAccessoryType:accessoryType];
    } else {
        [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.2 forAccessoryType:accessoryType];
    }
    */

    
 //   [[TGAccessoryManager sharedTGAccessoryManager] setDelegate:(TableViewController *)[[navigationController viewControllers] objectAtIndex:0]];
    
    //[[TGAccessoryManager sharedTGAccessoryManager] setRawEnabled:rawEnabled];
    
    
    // Override point for customization after application launch.
    return YES;
    
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
