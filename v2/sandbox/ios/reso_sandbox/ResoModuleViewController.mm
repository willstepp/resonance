//
//  ResoModuleViewController.mm
//  reso_sandbox
//
//  Created by Daniel Stepp on 5/14/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoAppDelegate.h"
#import "ResoModuleViewController.h"
#import "ResoSoundLibraryViewController.h"

#import "ResoModuleManager.h"
#import "ResoModule.h"

@interface ResoModuleViewController ()
{
  ResoModule * module;
  UIImageView * backgroundImage;
  UILabel * soundLabel;
}
@end

@implementation ResoModuleViewController
@synthesize backButton, soundLibraryButton, playButton, reverbSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
        NSLog(@"module view for %i", ad.currentModule);
      
        //background image
        backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:backgroundImage];
      
        //back button
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setTitle:@"<" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [backButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        backButton.layer.borderColor = [UIColor blackColor].CGColor;
        backButton.layer.borderWidth = 0.0f;
        backButton.layer.cornerRadius = 4.0f;
        backButton.frame = CGRectMake(10, 10, 44, 44);
        [self.view addSubview:backButton];
      
        //player button
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setTitle:@"Play Sound" forState:UIControlStateNormal];
        [playButton addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
        [playButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [playButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        playButton.layer.borderColor = [UIColor blackColor].CGColor;
        playButton.layer.borderWidth = 0.0f;
        playButton.layer.cornerRadius = 4.0f;
        playButton.frame = CGRectMake(10, 180, self.view.bounds.size.width - 20, 50);
        [self.view addSubview:playButton];
        
        //reverb label
        UILabel * reverbLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 30, 250, 65, 26)];
        [reverbLabel setText:@"Reverb"];
        [reverbLabel setBackgroundColor:[UIColor clearColor]];
        [reverbLabel setTextColor:[UIColor whiteColor]];
        [self.view addSubview:reverbLabel];
        
        //reverb switch
        CGRect frame = CGRectMake((self.view.bounds.size.width / 2) - 40, 280, 60.0, 26.0);
        reverbSwitch = [[UISwitch alloc] initWithFrame:frame];
        [reverbSwitch setTintColor:[UIColor blackColor]];
        [reverbSwitch setOnTintColor:[UIColor lightGrayColor]];
        [reverbSwitch setThumbTintColor:[UIColor grayColor]];
        [reverbSwitch addTarget:self action:@selector(toggleReverb:) forControlEvents:UIControlEventTouchUpInside];
        
        [reverbSwitch setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:reverbSwitch];
      
        //sound library button
        soundLibraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [soundLibraryButton setTitle:@"Sound Library" forState:UIControlStateNormal];
        [soundLibraryButton addTarget:self action:@selector(showSoundLibrary:) forControlEvents:UIControlEventTouchUpInside];
        [soundLibraryButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
        [soundLibraryButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
        
        soundLibraryButton.layer.borderColor = [UIColor blackColor].CGColor;
        soundLibraryButton.layer.borderWidth = 0.0f;
        soundLibraryButton.layer.cornerRadius = 4.0f;
        soundLibraryButton.frame = CGRectMake(10, self.view.bounds.size.height - 60, self.view.bounds.size.width - 20, 50);
        [self.view addSubview:soundLibraryButton];
      
        soundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 125, self.view.bounds.size.width - 20, 50)];
        
        [self.view setBackgroundColor:[UIColor darkGrayColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];

  ResoModuleManager * rmm = [ResoModuleManager instance];
  module = [rmm.modules objectForKey:[NSNumber numberWithInt:ad.currentModule]];
  if ([module.sound loaded]) {
    
    if ([module.sound playing]) {
      [playButton setTitle:@"Stop Sound" forState:UIControlStateNormal];
    }
    
    //load background image
    NSString * backgroundPath = [[ad resonanceAppSubDirectory:[NSString stringWithFormat:@"sounds/%@/img_blur", module.uuid]] path];
    [backgroundImage setImage:[UIImage imageWithContentsOfFile:backgroundPath]];
    
    //load sound title
    NSMutableDictionary * sound = [ad soundWithIdentifier:module.uuid];
    [soundLabel setText:[sound objectForKey:@"name"]];
    [soundLabel setBackgroundColor:[UIColor clearColor]];
    [soundLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:soundLabel];
    
    [reverbSwitch setOn:[module.sound hasEffectOfType:Reverb]];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack:(id)sender
{
  [self.navigationController popViewControllerAnimated:YES];
}

-(void)playSound:(id)sender
{
  ResoModuleManager * rmm = [ResoModuleManager instance];
  ResoAppDelegate * ad = (ResoAppDelegate*)[[UIApplication sharedApplication]delegate];
  module = [rmm.modules objectForKey:[NSNumber numberWithInt:ad.currentModule]];
  if ([module.sound loaded]) {
    if ([module.sound playing]) {
      [playButton setTitle:@"Play Sound" forState:UIControlStateNormal];
      [module.sound stop];
    } else {
      [playButton setTitle:@"Stop Sound" forState:UIControlStateNormal];
      [module.sound play];
      NSLog(@"%f", [module.sound volume]);
    }
  }
}

-(void)toggleReverb:(id)sender
{
  if ([reverbSwitch isOn]) {
    [module.sound addEffectOfType:Reverb];
    [module.sound setEffectValueForType:Reverb forParameter:Reverb_Room withValue:0.0f];
  } else {
    [module.sound removeEffectOfType:Reverb];
  }
}

-(void)showSoundLibrary:(id)sender
{
  ResoSoundLibraryViewController * rslvc = [[ResoSoundLibraryViewController alloc] initWithNibName:nil bundle:nil];
  [self.navigationController pushViewController:rslvc animated:YES];
}

@end
