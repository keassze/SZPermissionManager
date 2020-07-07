//
//  SZLibraryCameraUtils.h
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/1.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SZPermissionManager;
@class SZImageModel;
NS_ASSUME_NONNULL_BEGIN

typedef void(^SZLiraryCallback) (NSError *_Nullable error,NSArray<SZImageModel *> *_Nullable images);

@interface SZLibraryCameraUtils : NSObject

+ (instancetype)shareUtils;

- (void)openLibraryBySuperVC:(UIViewController *)superVC
                    callback:(nullable SZLiraryCallback)callback;

- (void)openCameraBySuperVC:(UIViewController *)superVC
                   callback:(nullable SZLiraryCallback)callback;

@end

NS_ASSUME_NONNULL_END
