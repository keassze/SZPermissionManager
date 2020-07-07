//
//  SZLocationUtils.h
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/2.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SZLocationCallback) (NSError *_Nullable error,CLLocationCoordinate2D coordinate2D);

typedef NS_ENUM(NSUInteger, SZLocationType) {
    SZLocationTypeWhenInUse,
    SZLocationTypeAlways,
};

@interface SZLocationUtils : NSObject

/** kCLDistanceFilterNone:随时更新 CLLocationDistanceMax:更新最大的距离限制 */
@property (nonatomic, assign) double distanceFilter;
/**
 * 请求的定位类型 - 默认只有前台使用
 * 设置前，确保Info.plist有相应类型的key值
 */
@property (nonatomic, assign) SZLocationType locationType;

+ (instancetype)shareUtils;
- (void)openMapViewControllerOnSuperVC:(UIViewController *)superVC
                              callback:(SZLocationCallback)callback;



@end

NS_ASSUME_NONNULL_END
