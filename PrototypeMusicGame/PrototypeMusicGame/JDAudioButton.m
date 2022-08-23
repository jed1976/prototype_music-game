//
//  JDAudioButton
//  Prototype1
//
//  Created by Joe Dakroub on 7/27/12.
//  Copyright (c) 2012 Joe Dakroub. All rights reserved.
//

#import "JDAudioButton.h"

CGFloat kButtonSize = 44.0;

@interface JDAudioButton()
{
    NSTimeInterval startTime;
    NSTimeInterval duration;
    NSTimer *durationTimer;
}

@end

@implementation JDAudioButton

+ (CGFloat)buttonSize
{
    return kButtonSize;
}

- (id)initWithOrigin:(CGPoint)origin URL:(NSURL *)url startTime:(NSTimeInterval)time duration:(NSTimeInterval)theDuration
{
    if (self = [super initWithFrame:CGRectMake(origin.x, origin.y, kButtonSize, kButtonSize)])
    {
        [self addObserver:self
               forKeyPath:@"frame"
                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                  context:NULL];
        
        [self setIsMovable:YES];
        
        // Visual properties
        [[self layer] setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [[self layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[self layer] setBorderWidth:1.0];
        
        [self setShowsTouchWhenHighlighted:YES];
        
        [self setAutoresizesSubviews:UIViewAutoresizingFlexibleLeftMargin];
        
        // Prepare audio player
        [self setAudioPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL]];
        [[self audioPlayer] prepareToPlay];
        
        [self setPanBasedOnLocation];
        
        // Times
        startTime = time;
        duration = theDuration;
        
        // Actions
        [self addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(stopSound:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqual:@"frame"])
    {
        [self setDestinationRect:[self frame]];
    }
}

- (void)highlightButton;
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    [self setBackgroundColor:[UIColor greenColor]];
    [UIView commitAnimations];
}

#pragma -
#pragma Audio playback

- (void)setPanBasedOnLocation
{
    [[self audioPlayer] setPan:((self.center.x / [[self superview] bounds].size.width) * 2 - 1)];
}

- (void)playSound:(id)sender
{
    [[self superview] bringSubviewToFront:self];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    [self setAlpha:0.7];
    [UIView commitAnimations];
    
    // Play
    [[self audioPlayer] setCurrentTime:startTime];
    [[self audioPlayer] setVolume:1.0];
    [[self audioPlayer] play];
    
    // Timer
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                     target:self
                                                   selector:@selector(pauseThenRepeat:)
                                                   userInfo:nil
                                                    repeats:NO];
    
    // Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioButtonDidBeginPlaying" object:self];
}

- (void)pauseThenRepeat:(id)sender
{
    [durationTimer invalidate];

    [[self audioPlayer] pause];

    // Repeat play
    durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                     target:self
                                                   selector:@selector(playSound:)
                                                   userInfo:nil
                                                    repeats:NO];
}

- (void)stopSound:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.15];
    [self setAlpha:1.0];
    [self setFrame:[self destinationRect]];
    [UIView commitAnimations];
    
    // Fade sound
    [self performSelector:@selector(fadeVolumeDown:)
               withObject:[self audioPlayer]
               afterDelay:0.1
                  inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)fadeVolumeDown:(id)sender
{
    [[self audioPlayer] setVolume:[[self audioPlayer] volume] - 0.35];

    if ([[self audioPlayer] volume] < 0.1)
    {
        [durationTimer invalidate];
        
        // Pause
        [[self audioPlayer] pause];
        [[self audioPlayer] setCurrentTime:startTime];
        
        // Notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioButtonDidStopPlaying" object:self];
    }
    else
    {
        [self performSelector:@selector(fadeVolumeDown:) withObject:[self audioPlayer] afterDelay:0.1];
    }
}

@end
