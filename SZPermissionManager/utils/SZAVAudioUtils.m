//
//  SZAVAudioUtils.m
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/6.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import "SZAVAudioUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface SZAVAudioUtils()

@property (nonatomic, strong) AVAudioSession *audioSession;

@end

@implementation SZAVAudioUtils

+ (instancetype)shareUtils
{
    static SZAVAudioUtils *_utils = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utils = [[SZAVAudioUtils alloc] init];
        _utils.audioSession = [AVAudioSession sharedInstance];
    });
    return _utils;
}

- (void)startRecord
{
    NSError *error = nil;
    [self.audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    
}

@end
