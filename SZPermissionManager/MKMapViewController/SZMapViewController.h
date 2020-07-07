//
//  SZMapViewController.h
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/2.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SZMapViewController : UIViewController

@property (nonatomic, strong) CLLocationManager *locationManager;
/** 纬度范围 default-0.05 与显示范围正相关 */
@property (nonatomic, assign) double latitudeSpan;
/** 经度范围 default-0.05 与显示范围正相关 */
@property (nonatomic, assign) double longitudeSpan;
/** 是否使用用户位置 - YES:地图经纬度参数无效 NO:请设置地图经纬度 */
@property (nonatomic, assign) BOOL isUserLocation;
/** 地图经纬度 default-(0,0)*/
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;

/**
 初始化方法，如果不需要用户定位，请设置为NO，并设置参数coordinate2D

 @param isUserLocation 是否使用用户定位（default - YES）
 @param callback 回调当前经纬度
 @return self
 */
- (instancetype)initWithUserLocation:(BOOL)isUserLocation callback:(void(^)(CLLocationCoordinate2D coordinate2D))callback;

@end

NS_ASSUME_NONNULL_END
