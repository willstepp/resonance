//
//  ResoAppDelegate.m
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import "ResoAppDelegate.h"

#import "ResoPlayerViewController.h"
#import "ResoPondViewController.h"
#import "IResoVisualization.h"
#import "ResoDataManager.h"
#import "ResoFileManager.h"
#import "ResoModuleManager.h"
#import "ResoModule.h"
#import "ISound.h"
#import "ITone.h"

@implementation ResoAppDelegate

@synthesize currentModule = _currentModule;
@synthesize currentModulePosition = _currentModulePosition;
@synthesize visualization, currPlayerState, playing, masterVolume;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  currPlayerState = PlayerState_Visual;
  _currentModule = nil;
  _currentModulePosition = -1;
  playing = false;
  masterVolume = 50;
  
  ResoPlayerViewController * player = [[ResoPlayerViewController alloc] init];
  UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:player];
  [nav setNavigationBarHidden:YES];
  
  ResoPondViewController * pond = [[ResoPondViewController alloc] init];
  visualization = pond;
  
  [pond addChildViewController:nav];
  [pond.view addSubview:nav.view];
  [nav didMoveToParentViewController:pond];
  
  [self.window setRootViewController:pond];
  [self.window makeKeyAndVisible];

  [application setApplicationSupportsShakeToEdit:YES];
  
  [ResoFileManager ensureResonanceAppDirectoryExists];
  [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:@"sounds"]];
  [ResoFileManager ensureDirectoryExists:[ResoFileManager resonanceAppSubDirectory:@"mixes"]];
  
  [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
  [[AVAudioSession sharedInstance] setActive: YES error: nil];
  [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
  
  //setup preview module
  ResoModuleManager * rmm = [ResoModuleManager instance];
  [rmm addModuleWithUuid:@"preview"];
  
  /*ResoDataManager * rdm = [ResoDataManager instance];
  [rdm clearSounds];
  [rdm clearMixes];*/
  
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
  [visualization enableAnimations:false];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [visualization enableAnimations:true];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  ResoDataManager * rdm = [ResoDataManager instance];
  [rdm saveContext];
}

-(void)updateMasterVolume:(int)newVolume
{
  //1) update master volume
  masterVolume = newVolume;
  
  //2) update all current modules based on new volume
  ResoModuleManager * rmm = [ResoModuleManager instance];
  for (id key in rmm.modules) {
    ResoModule * rm = [rmm.modules objectForKey:key];
    float actualVolume = [self calculateActualVolume:rm.volume];
    [rm updateVolume:actualVolume];
  }
}

-(void)playAll
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  [rmm playModules];
  playing = true;
}

-(void)pauseAll
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  [rmm pauseModules];
  playing = false;
}

-(float)calculateActualVolume:(int)moduleVolume
{
  float percentage = (float)self.masterVolume / 100.0f;
  return moduleVolume * percentage;
}

NSString * deviceName()
{
  struct utsname systemInfo;
  uname(&systemInfo);
  
  return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

/*
 @"i386"      on the simulator
 @"iPod1,1"   on iPod Touch
 @"iPod2,1"   on iPod Touch Second Generation
 @"iPod3,1"   on iPod Touch Third Generation
 @"iPod4,1"   on iPod Touch Fourth Generation
 @"iPod5,1"   on iPod Touch Fifth Generation
 @"iPhone1,1" on iPhone
 @"iPhone1,2" on iPhone 3G
 @"iPhone2,1" on iPhone 3GS
 @"iPad1,1"   on iPad
 @"iPad2,1"   on iPad 2
 @"iPad3,1"   on 3rd Generation iPad
 @"iPhone3,1" on iPhone 4
 @"iPhone4,1" on iPhone 4S
 @"iPhone5,1" on iPhone 5 (model A1428, AT&T/Canada)
 @"iPhone5,2" on iPhone 5 (model A1429, everything else)
 @"iPad3,4" on 4th Generation iPad
 @"iPad2,5" on iPad Mini
 */

-(NSString*)iosVersionForDownload
{
  NSString * version;
  NSString * deviceVersion = deviceName();
  
  if(([deviceVersion rangeOfString:@"iPhone5"].location != NSNotFound) ||
     ([deviceVersion rangeOfString:@"iPod5"].location != NSNotFound) ) {
    version = @"iphone5";
  } else if (([deviceVersion rangeOfString:@"iPhone4,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPhone3,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPod4"].location != NSNotFound)) {
    version = @"iphone4";
  } else if (([deviceVersion rangeOfString:@"iPhone1,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPhone1,2"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPhone2,1"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"iPod"].location != NSNotFound) ||
             ([deviceVersion rangeOfString:@"86"].location != NSNotFound)) {
    version = @"iphone";
  } else {
    version = @"";
  }
  
  return version;
}

+ (CGRect) windowFrame
{
  return [UIScreen mainScreen].applicationFrame;
}

+ (CGFloat) windowHeight
{
  return [UIScreen mainScreen].applicationFrame.size.height;
}

+ (CGFloat) windowWidth
{
  return [UIScreen mainScreen].applicationFrame.size.width;
}

@end
