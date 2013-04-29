//
//  ResoSoundViewController.h
//  reso_sandbox
//
//  Created by Daniel Stepp on 4/29/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResoSoundViewController : UIViewController
  @property (weak, nonatomic) IBOutlet UIButton * loadButton;
  @property (weak, nonatomic) IBOutlet UIButton * playButton;
  @property (weak, nonatomic) IBOutlet UIButton * pauseButton;
  @property (weak, nonatomic) IBOutlet UIButton * reverbButton;
  @property (weak, nonatomic) IBOutlet UISlider * reverbSlider;
  @property (weak, nonatomic) IBOutlet UISlider * volumeSlider;
  @property (weak, nonatomic) IBOutlet UIButton * recordButton;
  @property (weak, nonatomic) IBOutlet UIButton * backButton;

  - (IBAction)loadUnloadSound:(id)sender;
  - (IBAction)playStopSound:(id)sender;
  - (IBAction)pauseUnpauseSound:(id)sender;
  - (IBAction)enableDisableReverb:(id)sender;
  - (IBAction)changeReverbLevel:(id)sender;
  - (IBAction)changeSoundVolume:(id)sender;
  - (IBAction)startStopRecording:(id)sender;
  - (IBAction)goBack:(id)sender;
@end
