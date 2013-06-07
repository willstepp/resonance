//
//  GLIRViewController.m
//  gl_image_ripple
//
//  Created by Daniel Stepp on 9/1/12.
//  Copyright (c) 2012 Monomyth Software. All rights reserved.
//

#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <QuartzCore/QuartzCore.h>
#include <stdlib.h>
#import "ResoPondViewController.h"
#import "RippleModel.h"

#import "ResoSettings.h"
#import "ResoFileManager.h"

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

@interface ResoPondViewController (){
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
  
  NSString * _imageName;
  
  VisualizationState currentState;
  VisualizationState transitionState;
  
  NSString * activeSound;
  NSString * transitionSound;
  NSString * defaultSound;
  
  NSMutableArray * sounds;
  bool inputEnabled;
  
  NSTimer * transitionTimer;
  NSTimer * rainDropTimer;
  
  UIImageView * overlay;
}
@property (strong, nonatomic) EAGLContext * context;
- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;
@end

@implementation ResoPondViewController
@synthesize context = _context;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    sounds = [[NSMutableArray alloc] init];
    delegates = [[NSMutableArray alloc] init];
    
    defaultSound = @"reso-bg";
    
    inputEnabled = false;
    transitionState = Background;
    currentState = Background;
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
  
  activeSound = nil;
  transitionSound = nil;
  
  _imageName = activeSound;
  
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
  
  UIImage * myImage = [self getSoundImage:nil forState:currentState];
  CGImageRef imageRef = [myImage CGImage];
  imageRef = [self CGImageRotatedByAngle:imageRef angle:90.0f];
  _pixelBuffer = [self pixelBufferFromCGImage:imageRef];
  _width = CVPixelBufferGetWidth(_pixelBuffer);
  _height = CVPixelBufferGetHeight(_pixelBuffer);
  
  //-- Create CVOpenGLESTextureCacheRef for optimal CVImageBufferRef to GLES texture conversion.
  CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge CVEAGLContext)((__bridge void *)_context), NULL, &_textureCache);
  if (err)  {
    NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
  }
  
  //load overlay view
  overlay = [[UIImageView alloc] initWithFrame:self.view.bounds];
  overlay.alpha = 0.0f;
  [self.view addSubview:overlay];
  
  //start transition timer
  [self enableTransitions:true];
  
  //start rain drop timer
  rainDropTimer = [NSTimer scheduledTimerWithTimeInterval:47 target:self selector:@selector(makeItRain) userInfo:nil repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
  
  [self becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
  return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (motion == UIEventSubtypeMotionShake) {
    [self makeItRain];
  }
  [super motionBegan:motion withEvent:event];
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
  
  [transitionTimer invalidate];
  [rainDropTimer invalidate];
  
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
    [EAGLContext setCurrentContext:nil];
  }
  self.context = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)changeActiveSound
{
  if ([sounds count] > 0) {
  NSString * sound = [sounds objectAtIndex:(arc4random() % [sounds count])];
  if (![sound isEqualToString:activeSound] && currentState != Transitioning) {
    [self transitionToSound:sound];
  }
  } else {
    [self transitionToSound:nil];
  }
}

- (void)transitionToSound:(NSString*)uuid
{
  NSString * soundId = uuid != nil ? uuid : defaultSound;
  
  //1) set state to transitioning
  transitionState = currentState;
  currentState = Transitioning;
  
  //2) set transition sound id
  transitionSound = soundId;
  
  //3) setup overlay
  overlay.alpha = 0.0f;
  UIImage * overlayImage = [self getSoundImage:uuid forState:transitionState];
  [overlay setImage:overlayImage];
  
  //4) start an animation to increase the opacity of the overlay over 1 second
  [UIView animateWithDuration:VISUAL_TRANSITION_DURATION_SLOW
                        delay:0.00
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                     overlay.alpha = 1.0f;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       [self loadImageIntoPond:overlayImage];
                     }
                   }];
}

- (void)transitionToState:(VisualizationState)vs
{
  //1) set state to transitioning
  transitionState = vs;
  currentState = Transitioning;
  
  //2) set transition sound id
  transitionSound = activeSound;
  
  //2) setup overlay
  overlay.alpha = 0.0f;
  UIImage * overlayImage = [self getSoundImage:activeSound forState:vs];
  [overlay setImage:overlayImage];

  //3) start an animation to increase the opacity of the overlay over 1 second
  [UIView animateWithDuration:VISUAL_TRANSITION_DURATION_SLOW
                        delay:0.00
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                     overlay.alpha = 1.0f;
                   } completion:^(BOOL finished) {
                     if (finished) {
                       [self loadImageIntoPond:overlayImage];
                     }
                   }];
}

-(UIImage*)getSoundImage:(NSString*)uuid forState:(VisualizationState)vs
{
  UIImage * soundImage = nil;
  if (uuid != nil) {
    //load sound image
    NSString * imagePath = (vs == Foreground) ? [NSString stringWithFormat:@"sounds/%@/img", uuid] : [NSString stringWithFormat:@"sounds/%@/img_blur", uuid];
    NSString * image = [[ResoFileManager resonanceAppSubDirectory:imagePath] path];
    NSLog(@"image path: %@", image);
    soundImage = [UIImage imageWithContentsOfFile:image];
  } else {
    //load default image
    NSString * imagePath = (vs == Foreground) ? [NSString stringWithFormat:@"%@@2.jpg", defaultSound] : [NSString stringWithFormat:@"%@-blur@2.jpg", defaultSound];
    soundImage = [UIImage imageNamed:imagePath];
  }
  return soundImage;
}

-(void)loadImageIntoPond:(UIImage *)image
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
  
  if (currentState == Transitioning) {
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(completeTransition) userInfo:nil repeats:NO];
  }
}

- (void)completeTransition
{
  currentState = transitionState;
  activeSound = transitionSound;
  overlay.alpha = 0.0f;
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
    UIImage * image = [self getSoundImage:nil forState:Background];
    [self loadImageIntoPond:image];
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

#pragma mark IVisualization protocol methods

-(void)setVisualizationState:(VisualizationState)vs
{
  if (currentState != vs && currentState != Transitioning) {
    [self transitionToState:vs];
    [self notifyStateChanged:vs];
  }
}

-(VisualizationState)visualizationState
{
  return currentState;
}

-(void)enableTransitions:(bool)enable
{
  if (enable) {
    if (transitionTimer) [transitionTimer invalidate];
    transitionTimer = [NSTimer scheduledTimerWithTimeInterval:73 target:self selector:@selector(changeActiveSound) userInfo:nil repeats:YES];
  } else {
    [transitionTimer invalidate];
  }
}

-(void)refreshVisual
{
  [self changeActiveSound];
}

-(NSArray*)sounds
{
  return sounds;
}

-(void)addSound:(NSString*)uuid
{
  [sounds addObject:uuid];
}

-(void)removeSound:(NSString*)uuid
{
  [sounds removeObject:uuid];
}

-(NSString*)activeSound
{
  return activeSound;
}

-(void)setActiveSound:(NSString*)uuid
{
  if (activeSound != uuid && currentState != Transitioning) {
    [self transitionToSound:uuid];
    [self notifySoundChanged:uuid];
  }
}

-(bool)inputEnabled
{
  return inputEnabled;
}

-(void)setInputEnabled:(bool)enabled
{
  inputEnabled = enabled;
}

#pragma mark ResoVisualizationDelegate methods

- (NSMutableArray*)delegates
{
  return delegates;
}

- (void)addDelegate:(id<ResoVisualizationDelegate>)d
{
  [delegates addObject:d];
}

- (void)removeDelegate:(id<ResoVisualizationDelegate>)d
{
  [delegates removeObject:d];
}

#pragma mark delegate notifications

- (void) notifySoundChanged:(NSString*)uuid
{
  for(id<ResoVisualizationDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(activeSoundChanged:)] ) {
      [delegate performSelector:@selector(activeSoundChanged:) withObject:uuid];
    }
  }
}

- (void) notifyStateChanged:(VisualizationState)newState
{
  for(id<ResoVisualizationDelegate> delegate in delegates) {
    if ( [delegate respondsToSelector:@selector(visualizationStateChanged:)] ) {
      [delegate performSelector:@selector(visualizationStateChanged:) withObject:[NSNumber numberWithInt:newState]];
    }
  }
}


#pragma mark - Touch handling methods

- (void)myTouch:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches)
  {
    CGPoint location = [touch locationInView:touch.view];
    [_ripple initiateRippleAtLocation:location];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (inputEnabled) {
    [self myTouch:touches withEvent:event];
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  if (inputEnabled) {
    [self myTouch:touches withEvent:event];
  }
}
@end