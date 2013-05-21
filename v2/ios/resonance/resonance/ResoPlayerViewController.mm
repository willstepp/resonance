//
//  ResoPlayerViewController.m
//  resonance
//
//  Created by Daniel Stepp on 5/20/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ResoPlayerViewController.h"

#import "ResoModuleViewController.h"
#import "ResoMixViewController.h"
#import "ResoTimerViewController.h"

@interface ResoPlayerViewController ()

@end

@implementation ResoPlayerViewController
@synthesize mixButton, timerButton, moduleButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
      [self.view setBackgroundColor:[UIColor clearColor]];
      
      //module button
      moduleButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [moduleButton setTitle:@"Module" forState:UIControlStateNormal];
      [moduleButton addTarget:self action:@selector(showModule:) forControlEvents:UIControlEventTouchUpInside];
      [moduleButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [moduleButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      moduleButton.layer.borderColor = [UIColor blackColor].CGColor;
      moduleButton.layer.borderWidth = 0.0f;
      moduleButton.layer.cornerRadius = 4.0f;
      moduleButton.frame = CGRectMake(10, 100, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:moduleButton];
      
      //mix button
      mixButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [mixButton setTitle:@"Mixes" forState:UIControlStateNormal];
      [mixButton addTarget:self action:@selector(showMix:) forControlEvents:UIControlEventTouchUpInside];
      [mixButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [mixButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      mixButton.layer.borderColor = [UIColor blackColor].CGColor;
      mixButton.layer.borderWidth = 0.0f;
      mixButton.layer.cornerRadius = 4.0f;
      mixButton.frame = CGRectMake(10, 170, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:mixButton];
      
      //timer button
      timerButton = [UIButton buttonWithType:UIButtonTypeCustom];
      [timerButton setTitle:@"Timer" forState:UIControlStateNormal];
      [timerButton addTarget:self action:@selector(showTimer:) forControlEvents:UIControlEventTouchUpInside];
      [timerButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
      [timerButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
      
      timerButton.layer.borderColor = [UIColor blackColor].CGColor;
      timerButton.layer.borderWidth = 0.0f;
      timerButton.layer.cornerRadius = 4.0f;
      timerButton.frame = CGRectMake(10, 240, self.view.bounds.size.width - 20, 50);
      [self.view addSubview:timerButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showMix:(id)sender
{
  ResoMixViewController * rmvc = [[ResoMixViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rmvc animated:YES];
}

-(void)showModule:(id)sender
{
  ResoModuleViewController * rmvc = [[ResoModuleViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rmvc animated:YES];
}

-(void)showTimer:(id)sender
{
  ResoTimerViewController * rtvc = [[ResoTimerViewController alloc] initWithNibName:nil bundle:nil];
  //push it onto the 'navigation stack'
  [self.navigationController pushViewController:rtvc animated:YES];
}

#pragma mark - Touch handling methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"ResoPlayerViewController::touchesBegan");
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSLog(@"ResoPlayerViewController::touchesMoved");
  [super touchesMoved:touches withEvent:event];
}


@end
