//
//  RESOViewController.m
//  gl_sandbox
//
//  Created by Daniel Stepp on 9/1/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <QuartzCore/QuartzCore.h>
#include <stdlib.h>
#import "RESOViewController.h"
#import "RippleModel.h"

// Uniform index.
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_RGB,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface RESOViewController (){
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    unsigned int _meshFactor;

    GLuint _program;
    CVImageBufferRef _pixelBuffer;
    
    size_t _width;
    size_t _height;
    
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef _texture;
    
    GLuint _positionVBO;
    GLuint _texcoordVBO;
    GLuint _indexVBO;
    
    EAGLContext *_context;
    RippleModel *_ripple;
    
    NSTimer * timer;
    NSTimer * _loadPondImageTimer;
  
    CGSize _newSize;
    CGRect _rect;
  
    NSString * _imageName;
    NSString * _blurImageName;
  
    bool _touchEnabled;
  
    CGFloat _mirX;
    CGFloat _mirY;
    CGFloat _mirW;
    CGFloat _mirH;
  
    ResoAppState _currAppState;
    bool _stateInTransition;
  
    //module frames (for animations)
    CGRect _moduleOnscreenFrame1;
    CGRect _moduleOnscreenFrame2;
    CGRect _moduleOnscreenFrame3;
  
    CGRect _moduleOffscreenFrameTop;
    CGRect _moduleOffscreenFrameBottom;
  
    CGRect _fullScreenRect;
  
    int _currModule;
  
    NSDictionary * _modules;

}
@property (strong, nonatomic) EAGLContext *context;
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;
@end

@implementation RESOViewController
@synthesize context = _context;

@synthesize mirButton;
@synthesize mirButton2;
@synthesize mirButton3;

@synthesize visualButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle
{
	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGImageAlphaPremultipliedFirst);
	CGContextSetAllowsAntialiasing(bmContext, YES);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
	CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
					   imgRef);
	
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
	
	return rotatedImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    _currAppState = Module;
    _stateInTransition = false;
    _touchEnabled = false;
  
    _imageName = @"oceanblue@2.jpg";
    _blurImageName = @"oceanblue-blur@2.jpg";

    //customize module buttons
  
    //one
    [mirButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [mirButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75]];
    [mirButton setTag:1];
    mirButton.layer.borderColor = [UIColor blackColor].CGColor;
    mirButton.layer.borderWidth = 0.5f;
    mirButton.layer.cornerRadius = 5.0f;
  
    //two
    [mirButton2 setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [mirButton2 setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75]];
    [mirButton2 setTag:2];
    mirButton2.layer.borderColor = [UIColor blackColor].CGColor;
    mirButton2.layer.borderWidth = 0.5f;
    mirButton2.layer.cornerRadius = 5.0f;
  
    //three
    [mirButton3 setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [mirButton3 setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75]];
    [mirButton3 setTag:3];
    mirButton3.layer.borderColor = [UIColor blackColor].CGColor;
    mirButton3.layer.borderWidth = 0.5f;
    mirButton3.layer.cornerRadius = 5.0f;
  
    //visual button
    [visualButton setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
    [visualButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
    
    visualButton.layer.borderColor = [UIColor blackColor].CGColor;
    visualButton.layer.borderWidth = 0.0f;
    visualButton.layer.cornerRadius = 5.0f;
  
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    self.preferredFramesPerSecond = 60;
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    view.contentScaleFactor = [UIScreen mainScreen].scale;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // meshFactor controls the ending ripple mesh size.
        // For example mesh width = screenWidth / meshFactor.
        // It's chosen based on both screen resolution and device size.
        _meshFactor = 8;
    }
    else
    {
        _meshFactor = 4;
    }
    
    [self setupGL];
    
    UIImage * myImage = [UIImage imageNamed:_imageName];
    CGImageRef imageRef = [myImage CGImage];
    imageRef = [self CGImageRotatedByAngle:imageRef angle:90.0f];
    _pixelBuffer = [self pixelBufferFromCGImage:imageRef];
    _width = CVPixelBufferGetWidth(_pixelBuffer);
    _height = CVPixelBufferGetHeight(_pixelBuffer);
    
    //-- Create CVOpenGLESTextureCacheRef for optimal CVImageBufferRef to GLES texture conversion.
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge CVEAGLContext)((__bridge void *)_context), NULL, &_textureCache);
    if (err)  {
        NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
        return;
    }
  
  _newSize = CGSizeMake(_width, _height);
  _rect = CGRectMake(0,0,_width,_height);
  
  //load overlay view
  _overlay.alpha = 0.0f;
  _overlay.frame = self.view.bounds;
  
  UIImage * overlayImage = [UIImage imageNamed:_blurImageName];
  [_overlay setImage:overlayImage];

    //start rain drp on 30 second timer
  timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(makeItRain) userInfo:nil repeats:YES];
  
  _mirX = mirButton.frame.origin.x;
  _mirY = mirButton.frame.origin.y;
  _mirW = mirButton.frame.size.width;
  _mirH = mirButton.frame.size.height;
  
  _moduleOnscreenFrame1 = mirButton.frame;
  _moduleOnscreenFrame2 = mirButton2.frame;
  _moduleOnscreenFrame3 = mirButton3.frame;
  
  _moduleOffscreenFrameTop = CGRectMake(mirButton.frame.origin.x, -100.0f, mirButton.frame.size.width, mirButton.frame.size.height);
  _moduleOffscreenFrameBottom = CGRectMake(mirButton.frame.origin.x, _screenHeight + 100.0f, mirButton.frame.size.width, mirButton.frame.size.height);
  
  _fullScreenRect = CGRectMake(0.0, 0.0, _screenWidth, _screenHeight);
  
  [mirButton setFrame:_moduleOffscreenFrameTop];
  [mirButton2 setFrame:_moduleOffscreenFrameTop];
  [mirButton3 setFrame:_moduleOffscreenFrameTop];
  
  _currModule = 0;
  
  _modules = [[NSMutableDictionary alloc] init];
  [_modules setValue:mirButton forKey:[NSString stringWithFormat:@"%i",mirButton.tag]];
  [_modules setValue:mirButton2 forKey:[NSString stringWithFormat:@"%i",mirButton2.tag]];
  [_modules setValue:mirButton3 forKey:[NSString stringWithFormat:@"%i",mirButton3.tag]];
  
  [self changeAppToState:Module];
}

- (void) changeAppToState:(ResoAppState)state
{
  _stateInTransition = true;
  
  NSLog(@"changeAppToState");
  
  [self unloadCurrentState];
  [self loadNewState:state];
  
  _currAppState = state;
  _stateInTransition = false;
}

- (void) unloadCurrentState
{
  if (_currAppState == Visual) {
    NSLog(@"unloadCurrentState : Visual");
    
  } else if (_currAppState == Module) {
    NSLog(@"unloadCurrentState : Module");
    
        
  } else if (_currAppState == ModuleExpand) {
    NSLog(@"unloadCurrentState : ModuleExpand");

    [_modules enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
      NSString * k = (NSString*)key;
      if (_currModule == [k intValue]) {
        
        //collapse it
        [UIView animateWithDuration:0.50
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                           UIButton * m = (UIButton*)obj;
                           [visualButton setAlpha:1.0f];
                           CGRect rect;
                           switch ([k intValue]) {
                             case 1:
                               rect = _moduleOnscreenFrame1;
                               break;
                             case 2:
                               rect = _moduleOnscreenFrame2;
                               break;
                             case 3:
                               rect = _moduleOnscreenFrame3;
                               break;
                             default:
                               rect = _moduleOnscreenFrame1;
                           }
                           m.frame = rect;
                           m.layer.cornerRadius = 7.0f;
                         } completion:NULL];
        
      } else {
        
        //show it
        [UIView animateWithDuration:0.50
                              delay:0.50
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                           UIButton * m = (UIButton*)obj;
                           [m setAlpha:1.0f];
                         } completion:NULL];
        
      }
    }];
  }
}

- (void) loadNewState:(ResoAppState) ns
{
  if (ns == Visual) {
    NSLog(@"loadNewState : Visual");
    [visualButton setTitle:@"M" forState:UIControlStateNormal];
    
    //modules (animate offscreen)
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       mirButton.frame = _moduleOffscreenFrameTop;
                     } completion:NULL];
    
    [UIView animateWithDuration:0.75
                          delay:0.15
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       mirButton2.frame = _moduleOffscreenFrameTop;
                     } completion:NULL];
    
    [UIView animateWithDuration:0.75
                          delay:0.30
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                       mirButton3.frame = _moduleOffscreenFrameTop;
                     } completion:NULL];
    
    //background
    UIImage * overlayImage = [UIImage imageNamed:_imageName];
    [_overlay setImage:overlayImage];
    
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    _overlay.alpha = 0.0f;
    
    [UIView beginAnimations:nil context:imageContext];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    NSTimeInterval delaytime = 1.0;
    [UIView setAnimationDuration:delaytime];
    [UIView setAnimationDelegate:self];
    _overlay.alpha = 1.0f;
    [UIView commitAnimations];
    
    _loadPondImageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(resetPond:) userInfo:[NSNumber numberWithBool:false] repeats:NO];
    _touchEnabled = true;
  } else if (ns == Module) {
    _touchEnabled = false;
    
    NSLog(@"loadNewState : Module");
    [visualButton setTitle:@"V" forState:UIControlStateNormal];
    
    //modules (animate onscreen)
    
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       mirButton3.frame = _moduleOnscreenFrame3;
                     } completion:NULL];
    
    [UIView animateWithDuration:0.75
                          delay:0.15
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       mirButton2.frame = _moduleOnscreenFrame2;
                     } completion:NULL];
    
    [UIView animateWithDuration:0.75
                          delay:0.30
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       mirButton.frame = _moduleOnscreenFrame1;
                     } completion:NULL];
    
    //background
    UIImage * overlayImage = [UIImage imageNamed:_blurImageName];
    [_overlay setImage:overlayImage];
    
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    _overlay.alpha = 0.0f;
    [UIView beginAnimations:nil context:imageContext];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    NSTimeInterval delaytime = 1.00;
    [UIView setAnimationDuration:delaytime];
    [UIView setAnimationDelegate:self];
    _overlay.alpha = 1.0f;
    [UIView commitAnimations];
    
    _loadPondImageTimer = [NSTimer scheduledTimerWithTimeInterval:1.00 target:self selector:@selector(resetPond:) userInfo:[NSNumber numberWithBool:true] repeats:NO];
  } else if (ns == ModuleExpand) {
    NSLog(@"loadNewState : ModuleExpand");

    [_modules enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
      NSString * k = (NSString*)key;
      if (_currModule == [k intValue]) {
        //expand it
        [UIView animateWithDuration:0.50
                              delay:0.50
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                           UIButton * m = (UIButton*)obj;
                           [visualButton setAlpha:0.0f];
                           m.frame = _fullScreenRect;
                           m.layer.cornerRadius = 0.0f;
                         } completion:NULL];
        
      } else {
        //hide it
        [UIView animateWithDuration:0.50
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                            UIButton * m = (UIButton*)obj;
                           [m setAlpha:0.0f];
                         } completion:NULL];

      }
    }];
    
  }
}

- (void)cleanUpTextures
{
    if (_texture)
    {
        CFRelease(_texture);
        _texture = NULL;
    }
    
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:NO], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glUseProgram(_program);
    
    glUniform1i(uniforms[UNIFORM_RGB], 0);
}

- (void)setupBuffers
{
    glGenBuffers(1, &_indexVBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexVBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, [_ripple getIndexSize], [_ripple getIndices], GL_STATIC_DRAW);
    
    glGenBuffers(1, &_positionVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _positionVBO);
    glBufferData(GL_ARRAY_BUFFER, [_ripple getVertexSize], [_ripple getVertices], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), 0);
    
    glGenBuffers(1, &_texcoordVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _texcoordVBO);
    glBufferData(GL_ARRAY_BUFFER, [_ripple getVertexSize], [_ripple getTexCoords], GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 2*sizeof(GLfloat), 0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:_context];
    
    glDeleteBuffers(1, &_positionVBO);
    glDeleteBuffers(1, &_texcoordVBO);
    glDeleteBuffers(1, &_indexVBO);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [timer invalidate];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
    _modules = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (_ripple)
    {
        unsigned int indexCount = [_ripple getIndexCount];
        glDrawElements(GL_TRIANGLE_STRIP, indexCount, GL_UNSIGNED_SHORT, 0);
    }
}

#pragma mark - GLKViewControllerDelegate

- (void)update
{
    if (!_textureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }
  
    if (!_ripple)
    {
        [self loadImageIntoPond:_blurImageName];
    }
    
    if (_ripple)
    {
        [_ripple runSimulation];
        
        // no need to rebind GL_ARRAY_BUFFER to _texcoordVBO since it should be still be bound from setupBuffers
        unsigned int vertexSize = [_ripple getVertexSize];
        GLfloat * texCoords = [_ripple getTexCoords];
        glBufferData(GL_ARRAY_BUFFER, vertexSize, texCoords, GL_DYNAMIC_DRAW);
    }
}

-(void)loadImageIntoPond:(NSString *)fileName
{
  [EAGLContext setCurrentContext:_context];
  
  glDeleteBuffers(1, &_positionVBO);
  glDeleteBuffers(1, &_texcoordVBO);
  glDeleteBuffers(1, &_indexVBO);
  
  if (_ripple) _ripple = nil;
  _ripple = [[RippleModel alloc] initWithScreenWidth:_screenWidth
                                        screenHeight:_screenHeight
                                          meshFactor:_meshFactor
                                         touchRadius:5
                                        textureWidth:_width
                                       textureHeight:_height];
  [self setupBuffers];
  
  glActiveTexture(GL_TEXTURE0);
  
  // 1
  UIImage * image = [UIImage imageNamed:fileName];
  CGImageRef spriteImage = image.CGImage;
  spriteImage = [self CGImageRotatedByAngle:spriteImage angle:90.0f];
  if (!spriteImage) {
    NSLog(@"Failed to load image %@", @"image");
    exit(1);
  }
  
  // 2
  _width = CGImageGetWidth(spriteImage);
  _height = CGImageGetHeight(spriteImage);
  
  GLubyte * spriteData = (GLubyte *) calloc(_width*_height*4, sizeof(GLubyte));
  
  CGContextRef spriteContext = CGBitmapContextCreate(spriteData, _width, _height, 8, _width*4,
                                                     CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
  
  // 3
  CGContextDrawImage(spriteContext, CGRectMake(0, 0, _width, _height), spriteImage);
  CGContextRelease(spriteContext);
  
  // 4
  GLuint texName;
  glGenTextures(1, &texName);
  glBindTexture(GL_TEXTURE_2D, texName);
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
  
  free(spriteData);
  
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

-(void)resetPond:(NSTimer*)currTimer
{
  NSNumber * ui = [currTimer userInfo];
  BOOL blurred = [ui boolValue];
  if (blurred) {
    NSLog(@"BLURRED");
    
    //load blurred curr image into pond
    [self loadImageIntoPond:_blurImageName];

  } else {
    NSLog(@"UNBLURRED");
    //load unblurred curr image into pond
    [self loadImageIntoPond:_imageName];
  }
  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showOverlay:) userInfo:[NSNumber numberWithBool:false] repeats:NO];
}

-(void)showOverlay:(NSTimer*)currTimer
{
  NSNumber * ui = [currTimer userInfo];
  BOOL show = [ui boolValue];
  if (show){
    NSLog(@"SHOW OVERLAY");
    _overlay.alpha = 1.0f;
  } else {
    NSLog(@"HIDE OVERLAY");
    _overlay.alpha = 0.0f;
  }
  [mirButton setEnabled:true];
}

-(IBAction)toggleModule:(id)sender
{
  _currModule = [sender tag];
  NSLog(@"%i", _currModule);

  if (!_stateInTransition) {
    if (_currAppState == Module) {
      [self changeAppToState:ModuleExpand];
    } else if (_currAppState == ModuleExpand) {
      [self changeAppToState:Module];
    }
  }
}

-(IBAction)toggleVisualState
{
  if (!_stateInTransition) {
    if (_currAppState == Visual) {
      [self changeAppToState:Module];
    } else if (_currAppState == Module) {
      [self changeAppToState:Visual];
    }
  }
}

-(void)makeItRain
{
  if (_ripple)
  {
    CGPoint location;
    location.x = arc4random_uniform(self.view.bounds.size.width);
    location.y = arc4random_uniform(self.view.bounds.size.height);
    
    [_ripple initiateRippleAtLocation:location];
  }
}

#pragma mark - OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIB_TEXCOORD, "texCoord");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_RGB] = glGetUniformLocation(_program, "SamplerRGB");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Touch handling methods

- (void)myTouch:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_touchEnabled) {
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:touch.view];
        [_ripple initiateRippleAtLocation:location];
    }
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_touchEnabled) {
    [self myTouch:touches withEvent:event];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (_touchEnabled) {
    [self myTouch:touches withEvent:event];
  }
}
@end
