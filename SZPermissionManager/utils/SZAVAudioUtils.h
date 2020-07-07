//
//  SZAVAudioUtils.h
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/6.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZAVAudioUtils : NSObject

+ (instancetype)shareUtils;

- (void)startRecord;

@end

NS_ASSUME_NONNULL_END
