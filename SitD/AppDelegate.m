//
//  AppDelegate.m
//  SitD
//
//  Created by rainwolf on 05/10/15.
//  Copyright © 2015 rainwolf. All rights reserved.
//

#import "AppDelegate.h"
#import "EntryViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    SitDNavigationViewController *navController = [[SitDNavigationViewController alloc] initWithRootViewController:[[EntryViewController alloc] init]];

//    NSBundle *cpaProxyBundle = [NSBundle bundleWithURL: [[NSBundle bundleForClass:NSClassFromString(@"CPAProxyManager")] URLForResource:@"CPAProxy" withExtension:@"bundle"]];
    NSString *destTorrc = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"torrc"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:destTorrc]) {
        [fileManager removeItemAtPath:destTorrc error: &error];
        if (error != nil) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    NSString *sourceTorrc = [[NSBundle mainBundle] pathForResource:@"torrc" ofType:nil];
    error = nil;
    [fileManager copyItemAtPath:sourceTorrc toPath:destTorrc error:&error];
    if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        if (![fileManager fileExistsAtPath:sourceTorrc]) {
            NSLog(@"(Source torrc %@ doesnt exist)", sourceTorrc);
        }
    }
//
//    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:destTorrc];
//    [myHandle seekToEndOfFile];
//    
//    [myHandle writeData:[@"\nUseBridges 1\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [myHandle writeData:[@"\nBridge obfs2 54.213.194.61:52176 4FC642D071EA16C4549C9D9EA6AE5F2E49046941\n" dataUsingEncoding:NSUTF8StringEncoding]];
//
//    [myHandle writeData:[@"ClientTransportPlugin obfs4 socks5 127.0.0.1:47351\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [myHandle writeData:[@"ClientTransportPlugin meek_lite socks5 127.0.0.1:47352\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [myHandle writeData:[@"ClientTransportPlugin obfs2 socks5 127.0.0.1:47353\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [myHandle writeData:[@"ClientTransportPlugin obfs3 socks5 127.0.0.1:47354\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [myHandle writeData:[@"ClientTransportPlugin scramblesuit socks5 127.0.0.1:47355\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [myHandle closeFile];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.rootViewController = navController;
    self.window.rootViewController = [[EntryViewController alloc] init];
    
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.

//    muahahahahahahahahahahahaaaaaaaaaaaaaaa
//    [UIView setAnimationsEnabled:NO];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
