//
//  GameViewController.h
//  Prototype1
//
//  Created by Joe Dakroub on 7/27/12.
//  Copyright (c) 2012 Joe Dakroub. All rights reserved.
//

#import "GameViewController.h"

CGFloat kAnimationDuration = 0.15;
CGFloat kButtonContainerDepth = 64.0;
CGFloat kButtonContainerPadding = 10.0;


@interface GameViewController ()
{
    AVAudioPlayer *audioPlayer;
    JDAudioButton *activeButton;
    
    NSMutableArray *audioButtons;
    NSTimer *timer;    
    
    NSInteger audioButtonCount;
    
    BOOL roundComplete;
}

@property (nonatomic, assign) NSInteger buttonsSolved;
@property (nonatomic, assign) NSInteger timeEllapsed;
@property (nonatomic, assign) BOOL audioPlaying;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set vars
    [self setAudioPlaying:NO];
    [self setButtonsSolved:0];
    [self setTimeEllapsed:-1];
    roundComplete = NO;
    
    // Notifications
    [self registerForNotifications];
    
    // Start timer
    [self startTimer];

    // Setup audio player    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"music" ofType:@"m4a"]];

    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [audioPlayer setDelegate:self];
    [audioPlayer prepareToPlay];
    
    // Create random audio buttons
    audioButtonCount = (arc4random() % 3) + 5;
    audioButtons = [[NSMutableArray alloc] initWithCapacity:audioButtonCount];
    
    [self createAudioButtonsWithURL:url
                          startTime:0.0
                           duration:[audioPlayer duration] / audioButtonCount];
    
    // Shuffle buttons
    [audioButtons shuffle];

    // Add buttons to container
    for (NSInteger i = 0; i < [audioButtons count]; i++)
    {
        JDAudioButton *button = [audioButtons objectAtIndex:i];
        [button setTag:i];
        [[self audioButtonContainer] addSubview:button];
    }
    
    [self layoutSubviewsWithOrientation:UIInterfaceOrientationPortrait];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pause:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [self addObserver:self
           forKeyPath:@"audioPlaying"
              options:(NSKeyValueObservingOptionNew)
              context:NULL];

    [self addObserver:self
           forKeyPath:@"buttonsSolved"
              options:(NSKeyValueObservingOptionNew)
              context:NULL];
    
    [self addObserver:self
           forKeyPath:@"timeEllapsed"
              options:(NSKeyValueObservingOptionNew)
              context:NULL];    
}

#pragma -
#pragma Flow methods

- (void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateTimer:)
                                           userInfo:nil
                                            repeats:YES];
}

- (IBAction)pause:(id)sender
{
    // Stop timer
    [timer invalidate];
    
    // Pause main audio if applicable
    if ([self audioPlaying])
        [audioPlayer pause];
    
    // Pause active button regardless
    [[activeButton audioPlayer] pause];
    
    // Fade in pause view
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [[self pauseViewContainer] setHidden:NO];
                         [[self pauseViewContainer] setAlpha:0.9];
                     }
                     completion:nil];    
}

- (void)resume:(id)sender
{
    // Resume main audio if applicable
    if ([self audioPlaying])
        [audioPlayer play];
    
    // Fade out pause view
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         [[self pauseViewContainer] setAlpha:0.0];
                     }
                     completion:^(BOOL finished) {
                         [[self pauseViewContainer] setHidden:YES];
                     }];

    // Start timer if applicable
    if (roundComplete == NO)
        [self startTimer];
}

#pragma -
#pragma Layout methods

- (void)createAudioButtonsWithURL:(NSURL *)url startTime:(NSTimeInterval)startTime duration:(NSTimeInterval)duration
{
    // Create audio buttons
    for (NSInteger i = 0; i < audioButtonCount; i++)
    {
        JDAudioButton *button = [[JDAudioButton alloc] initWithOrigin:CGPointZero
                                                              URL:url
                                                        startTime:(startTime + duration) * i
                                                         duration:duration];
        [button setGoalIndex:i];
        [[button titleLabel] setTag:2000]; // Needed so we can use tag to retrieve only AudioButtons
//        [[button titleLabel] setAlpha:0.0];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"%i", i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(wasDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [button addTarget:self action:@selector(dragEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(decreaseVolume:)
                                                     name:@"AudioButtonDidBeginPlaying"
                                                   object:button];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(increaseVolume:)
                                                     name:@"AudioButtonDidStopPlaying"
                                                   object:button];
        
        [audioButtons addObject:button];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [audioPlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutSubviewsWithOrientation:interfaceOrientation];
}

- (void)layoutSubviewsWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    
    if (toInterfaceOrientation)
        orientation = toInterfaceOrientation;
    
    // Layout buttons
    for (NSInteger i = 0; i < [audioButtons count]; i++)
    {
        JDAudioButton *button = [audioButtons objectAtIndex:i];
        [button setAutoresizingMask:UIViewAutoresizingNone];

        CGRect frame = [button frame];
        frame.origin.x = UIInterfaceOrientationIsLandscape(orientation)
                ? (((kButtonContainerPadding + frame.size.width) * i) + kButtonContainerPadding)
                : kButtonContainerPadding;;
        frame.origin.y = UIInterfaceOrientationIsLandscape(orientation)
                ? kButtonContainerPadding
                : ((kButtonContainerPadding + frame.size.height) * i) + kButtonContainerPadding;
        [button setFrame:frame];
    }
    
    // Set frame properties
    CGFloat containerSize = (([JDAudioButton buttonSize] + kButtonContainerPadding) * [audioButtons count]) + kButtonContainerPadding;
    
    CGFloat width = UIInterfaceOrientationIsLandscape(orientation) ? containerSize : kButtonContainerDepth;
    CGFloat height = UIInterfaceOrientationIsLandscape(orientation) ? kButtonContainerDepth : containerSize;
    CGFloat x = ([[[self audioButtonContainer] superview] frame].size.width / 2) - (width / 2) - 2;
    CGFloat y = ([[[self audioButtonContainer] superview] frame].size.height / 2) - (height / 2) - 2;
    
    [[self audioButtonContainer] setFrame:CGRectMake(x, y, width, height)];
}

- (void)updateTimer:(id)sender
{
    [self setTimeEllapsed:[self timeEllapsed] + 1];
}

#pragma -
#pragma Playback

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self setAudioPlaying:NO];
}

- (IBAction)toggleAudioPlayback:(id)sender
{
    [self setAudioPlaying:![self audioPlaying]];
}

- (void)decreaseVolume:(NSNotification *)note
{
    [audioPlayer setVolume:0.1];
}

- (void)increaseVolume:(NSNotification *)note
{
    [audioPlayer setVolume:1.0];
}

#pragma -
#pragma Dragging

- (IBAction)wasDragged:(JDAudioButton *)button withEvent:(UIEvent *)event
{
    if ([button isMovable] == NO)
        return;
    
    activeButton = button;
    
    // Get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
    
	// Get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat deltaX = location.x - previousLocation.x;
	CGFloat deltaY = location.y - previousLocation.y;
    
    // Relocate other buttons based on drag
    [self relocateButtonsBasedOnIntersection:button];
        
	// Move dragged button
    NSInteger x = UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? button.center.x + deltaX : button.center.x;
    NSInteger y = UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? button.center.y : button.center.y + deltaY;
    button.center = CGPointMake(x, y);
    
    // Pan audio
    [button setPanBasedOnLocation];
}

- (void)relocateButtonsBasedOnIntersection:(JDAudioButton *)button
{
    CGRect buttonRect = [button frame];
    
    // Determine button intersection with other buttons
    for (JDAudioButton *audioButton in audioButtons)
    {
        // Skip buttons that cannot move
        if (audioButton == button || [audioButton isMovable] == NO)
            continue;
        
        // Get midX/Y of btn to determine intersection with dragged button
        if (CGRectContainsPoint(buttonRect, CGPointMake(CGRectGetMidX([audioButton frame]), CGRectGetMidY([audioButton frame]))))
        {
            CGRect newDestinationRect = [audioButton frame];
            NSInteger tag = [audioButton tag];
            
            // Move btn to new location
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:kAnimationDuration];
            [audioButton setFrame:[button destinationRect]];
            [UIView commitAnimations];
            
            [audioButton setTag:[button tag]];
            
            // Update button's destination rect with previous btn rect
            [button setDestinationRect:newDestinationRect];
            [button setTag:tag];
        }
    }
}

- (IBAction)dragEnded:(JDAudioButton *)button withEvent:(UIEvent *)event
{
    [self updateButtonModel:button];
    [self checkIfButtonReachedItsGoal:button];
}

- (void)updateButtonModel:(JDAudioButton *)button
{
    // Update audio buttons model with new positions
    NSMutableArray *newAudioButtons = [NSMutableArray arrayWithCapacity:[audioButtons count]];
    
    for (NSInteger i = 0; i < [audioButtons count]; i++)
    {
        [newAudioButtons addObject:[[self audioButtonContainer] viewWithTag:i]];
    }
    
    audioButtons = [NSMutableArray arrayWithArray:newAudioButtons];
}

- (void)checkIfButtonReachedItsGoal:(JDAudioButton *)button
{
    // Determine if the dropped button is in the goal index
    for (NSInteger i = 0; i < [audioButtons count]; i++)
    {
        JDAudioButton *audioButton = [audioButtons objectAtIndex:i];
        
        if ([audioButton isMovable] == NO)
            continue;
        
        if (button == audioButton && [audioButton goalIndex] == i)
        {
            [self setButtonsSolved:[self buttonsSolved] + 1];
            
            [button setIsMovable:NO];
            [button highlightButton];
            
            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"audioPlaying"])
    {
        if ([[change objectForKey:NSKeyValueChangeNewKey] boolValue] == YES)
        {
            [[self playbackToggleButton] setTitle:@"Stop"];
            
            [audioPlayer play];
        }
        else
        {
            [[self playbackToggleButton] setTitle:@"Play"];
            
            [audioPlayer pause];
            [audioPlayer setCurrentTime:0.0];
        }
    }

    if ([keyPath isEqual:@"buttonsSolved"])
    {
        if ([[change objectForKey:NSKeyValueChangeNewKey] intValue] == [audioButtons count])
        {
            // Stop timer
            [timer invalidate];
            
            // Disable touches on button container
            [[self audioButtonContainer] setUserInteractionEnabled:NO];
            
            roundComplete = YES;
            
            NSLog(@"ROUND COMPLETE");
        }
    }

    if ([keyPath isEqual:@"timeEllapsed"])
    {
        [[self timerLabel] setTitle:[NSString stringWithFormat:@"%i", [self timeEllapsed]]];
    }
}

@end
