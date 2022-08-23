//
//  JDAudioButton
//  Prototype1
//
//  Created by Joe Dakroub on 7/27/12.
//  Copyright (c) 2012 Joe Dakroub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface JDAudioButton : UIButton

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) CGRect destinationRect;
@property (nonatomic, assign) NSInteger newViewIndex;
@property (nonatomic, assign) NSInteger goalIndex;
@property (nonatomic, assign) BOOL isMovable;

+ (CGFloat)buttonSize;
- (id)initWithOrigin:(CGPoint)origin URL:(NSURL *)url startTime:(NSTimeInterval)theStartTime duration:(NSTimeInterval)theEndTime;
- (void)setPanBasedOnLocation;
- (void)highlightButton;

@end
