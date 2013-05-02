#import "ResoSoundViewController.h"
#import "ResoAppDelegate.h"
#import "FMODSoundEngine.h"

#define __PACKED __attribute__((packed))    /* gcc packed */

@interface ResoSoundViewController ()
{
  id<ISoundEngine> player;
  id<ISound> sound;
  id<ITone> tone;
}
@end

@implementation ResoSoundViewController
@synthesize loadButton;
@synthesize playButton;
@synthesize pauseButton;
@synthesize reverbButton;
@synthesize reverbSlider;
@synthesize volumeSlider;
@synthesize recordButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  player = nil;
  sound = nil;
  tone = nil;
  
  [reverbSlider setMinimumValue:-10000.0f];
  [reverbSlider setMaximumValue:0.0f];
  [reverbSlider setValue:0.0f];
  
  [volumeSlider setMinimumValue:0.0f];
  [volumeSlider setMaximumValue:100.0f];
  [volumeSlider setValue:50.0f];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
  player = [FMODSoundEngine instance];
  sound = [player getSoundForId:Module::One];
  tone = [player getToneForId:Module::Two];
}

- (void)viewWillDisappear:(BOOL)animated
{
  sound = nil;
  tone = nil;
  player = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)goBack:(id)sender
{
  // goes back to the last view controller in the stack
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loadUnloadSound:(id)sender
{
  static bool loaded = false;
  if (!loaded)
  {
    [sound load:[NSString stringWithFormat:@"%@/drumloop.wav", [[NSBundle mainBundle] resourcePath]]];
    [tone load:ToneType::Binaural];
    [tone setPropertyOfType:ToneProperty::Frequency withValue:220.0f];
    [tone setPropertyOfType:ToneProperty::BinauralGap withValue:5.0f];
    [self.loadButton setTitle:@"Unload" forState:UIControlStateNormal];
    loaded = true;
  }
  else
  {
    [sound unload];
    [tone unload];
    [self.loadButton setTitle:@"Load" forState:UIControlStateNormal];
    loaded = false;
  }
}

- (IBAction)playStopSound:(id)sender
{
  static bool playing = false;
  if (!playing)
  {
    float normalized = [volumeSlider value] / 100.0f;
    [tone play];
    [tone setVolume:normalized];
    [sound play];
    [sound setVolume:normalized];
    
    [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
    playing = true;
  }
  else
  {
    [tone stop];
    [sound stop];
    
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    playing = false;
  }
}

- (IBAction)pauseUnpauseSound:(id)sender
{
  static bool paused = false;
  if (!paused)
  {
    [sound setPaused:true];
    [tone setPaused:true];
    [self.pauseButton setTitle:@"Unpause" forState:UIControlStateNormal];
    paused = true;
  }
  else
  {
    float normalized = [volumeSlider value] / 100.0f;
    [sound setPaused:false];
    [sound setVolume:normalized];
    [tone setPaused:false];
    [tone setVolume:normalized];
    [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    paused = false;
  }
}

- (IBAction)enableDisableReverb:(id)sender
{
  static bool reverbEnabled = false;
  if (!reverbEnabled)
  {
    [sound addEffectOfType:EffectType::Reverb];
    [sound setEffectValueForType:EffectType::Reverb forParameter:EffectParameter::Reverb_Room withValue:[reverbSlider value]];
    [self.reverbButton setTitle:@"Disable Reverb" forState:UIControlStateNormal];
    reverbEnabled = true;
  }
  else
  {
    [sound removeEffectOfType:EffectType::Reverb];
    [self.reverbButton setTitle:@"Enable Reverb" forState:UIControlStateNormal];
    reverbEnabled = false;
  }
}

- (IBAction)changeReverbLevel:(id)sender
{
  [sound setEffectValueForType:EffectType::Reverb forParameter:EffectParameter::Reverb_Room withValue:[reverbSlider value]];
}

- (IBAction)changeSoundVolume:(id)sender
{
  float normalized = [volumeSlider value] / 100.0f;
  [sound setVolume:normalized];
  [tone setVolume:normalized];
}

- (IBAction)startStopRecording:(id)sender
{
  static bool recording = false;
  static int recordingNumber = 0;
  if (recording)
  {
    [player stopRecording];
    recording = false;
    [self.recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
  }
  else
  {
    NSString * filename = [NSString stringWithFormat:@"%@/test_%@.wav", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [NSNumber numberWithInt:recordingNumber]];
    
    NSLog(@"%@", filename);
    
    [player startRecording:filename];
    
    recordingNumber++;
    recording = true;
    [self.recordButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
  }
}

@end
