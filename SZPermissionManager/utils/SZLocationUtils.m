//
//  SZLocationUtils.m
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/2.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import "SZLocationUtils.h"
#import "SZPermissionManager.h"
#import "SZMapViewController.h"

@interface SZLocationUtils()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) SZLocationCallback completion;

@end

@implementation SZLocationUtils

+ (instancetype)shareUtils
{
    static SZLocationUtils *_utils = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utils = [[SZLocationUtils alloc] init];
        _utils.locationManager = [[CLLocationManager alloc] init];
        _utils.locationManager.delegate = _utils;
        // 默认200
        _utils.locationManager.distanceFilter = 200;
    });
    return _utils;
}

- (void)setDistanceFilter:(double)distanceFilter
{
    _distanceFilter = distanceFilter;
    self.locationManager.distanceFilter = distanceFilter;
}

- (void)openMapViewControllerOnSuperVC:(UIViewController *)superVC
                              callback:(SZLocationCallback)callback
{
    __weak typeof(self)weakSelf = self;
    self.completion = callback;
    [[SZPermissionManager shareManager] getPermissionByType:SZPermissionTypeLocation callback:^(NSError * _Nullable error, SZPermissionType permissionType) {
        if (error.code == SZPermissionLocationUnable || error.code == SZPermissionLocationRestricted || error.code == SZPermissionLocationDenied) {
            [weakSelf showOpenPrivacyAlertTitle:@"需要您开启定位权限" message:@"" BySuperVC:superVC];
            if (callback) {
                callback(error,CLLocationCoordinate2DMake(0, 0));
            }
        }else if (error.code == SZPermissionLocationNotDetermined) {
            if (weakSelf.locationType == SZLocationTypeWhenInUse) {
                [weakSelf.locationManager requestWhenInUseAuthorization];
            }else {
                [weakSelf.locationManager requestAlwaysAuthorization];
            }
            if (callback) {
                callback(error,CLLocationCoordinate2DMake(0, 0));
            }
        }else {
            [self showMapViewControllerWithSuperVC:superVC];
        }
    }];
}

- (void)showOpenPrivacyAlertTitle:(NSString *)title
                          message:(nullable NSString *)message
                        BySuperVC:(UIViewController *)superVC
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [superVC presentViewController:alertController animated:YES completion:nil];
}

- (void)showMapViewControllerWithSuperVC:(UIViewController *)superVC
{
    __weak typeof(self)weakSelf = self;
    SZMapViewController *mapVC = [[SZMapViewController alloc] initWithUserLocation:YES callback:^(CLLocationCoordinate2D coordinate2D) {
        if (weakSelf.completion) {
            weakSelf.completion(nil, coordinate2D);
        }
    }];
    mapVC.locationManager = self.locationManager;
//    mapVC.longitudeSpan = 0.01;
    [superVC presentViewController:mapVC animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

@end
