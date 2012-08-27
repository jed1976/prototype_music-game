//
//  GameViewController.h
//  Prototype1
//
//  Created by Joe Dakroub on 7/27/12.
//  Copyright (c) 2012 Joe Dakroub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDAudioButton.h"
#import "NSMutableArray+Randomization.h"

@interface GameViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *playbackToggleButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *timerLabel;

@property (nonatomic, strong) IBOutlet UIView *audioButtonContainer;
@property (nonatomic, strong) IBOutlet UIView *pauseViewContainer;

- (IBAction)toggleAudioPlayback:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;

@end
