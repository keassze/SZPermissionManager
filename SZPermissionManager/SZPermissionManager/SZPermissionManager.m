//
//  SZPermissionManager.m
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/7/31.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import "SZPermissionManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UserNotifications/UserNotifications.h>
#import <HealthKit/HealthKit.h>

@interface SZPermissionManager()

//@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation SZPermissionManager

+ (instancetype)shareManager
{
    static SZPermissionManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[SZPermissionManager alloc] init];
    });
    return _manager;
}

- (void)getPermissionByType:(SZPermissionType)type
                   callback:(SZPermissionTypeCallback)callback
{
    if (type == SZPermissionTypeCamera || type == SZPermissionTypeLibrary) {
        UIImagePickerControllerSourceType sourceType = type == SZPermissionTypeCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            if (callback) {
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionHardDeviceNotWork userInfo:@{NSLocalizedDescriptionKey:@"硬件不支持该功能"}];
                callback(error, type);
            }
            return;
        }
    }
    
    switch (type) {
        case SZPermissionTypeCamera:
            [self getCameraPermissionWithCallback:callback];
            break;
        case SZPermissionTypeLibrary:
            [self getLibraryPermissionWithCallback:callback];
            break;
        case SZPermissionTypeAVAudio:
            [self getAVAudioPermissionWithCallback:callback];
            break;
        case SZPermissionTypeLocation:
            [self getLocationPermissionWithCallback:callback];
            break;
        case SZPermissionTypeCalender:
        case SZPermissionTypeReminder:
            [self getEventKitPermissionType:type withCallback:callback];
            break;
        case SZPermissionTypeContacts:
            [self getAddressBookPermissionWithCallback:callback];
            break;
        case SZPermissionTypeBluetooth:
            [self getBluetoothPermissionWithCallback:callback];
            break;
        case SZPermissionTypePush:
            [self getPushPermissionWithCallback:callback];
            break;
        default:
            break;
    }
}

- (void)getCameraPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            break;
        case AVAuthorizationStatusNotDetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionCameraNotDetermined userInfo:@{NSLocalizedDescriptionKey:@""}];
            break;
        case AVAuthorizationStatusRestricted:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionCameraRestricted userInfo:@{NSLocalizedDescriptionKey:@""}];
            break;
        case AVAuthorizationStatusDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionCameraDenied userInfo:@{NSLocalizedDescriptionKey:@""}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,SZPermissionTypeCamera);
    }];
}

- (void)getLibraryPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    __block NSError *error = nil;
    if (@available(iOS 8.0.0, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self dispatchMainCallBack:^{
                    if (status == PHAuthorizationStatusAuthorized) {
                        error = nil;
                    }else {
                        error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryFirstDenied userInfo:@{NSLocalizedDescriptionKey:@"用户第一次拒绝授权"}];
                    }
                    if (callback) {
                        callback(error,SZPermissionTypeLibrary);
                    }
                }];
            }];
        }else if (status == PHAuthorizationStatusRestricted) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryRestricted userInfo:@{NSLocalizedDescriptionKey:@"用户未获得该权限"}];
        }else if (status == PHAuthorizationStatusDenied) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
        }
        if (callback) {
            callback(error,SZPermissionTypeLibrary);
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        switch (status) {
            case ALAuthorizationStatusAuthorized:
                break;
            case ALAuthorizationStatusNotDetermined:
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
                break;
            case ALAuthorizationStatusRestricted:
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryRestricted userInfo:@{NSLocalizedDescriptionKey:@"用户未获得该权限"}];
                break;
            case ALAuthorizationStatusDenied:
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLibraryDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
                break;
            default:
                break;
        }
        [self dispatchMainCallBack:^{
            if (callback) {
                callback(error,SZPermissionTypeLibrary);
            }
        }];
#pragma clang diagnostic pop
    }
}

- (void)getAVAudioPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    // ios8.0以上
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRecordPermission permission = [audioSession recordPermission];
    NSError *error = nil;
    switch (permission) {
        case AVAudioSessionRecordPermissionGranted:
            break;
        case AVAudioSessionRecordPermissionUndetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionAudioUndetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            break;
        case AVAudioSessionRecordPermissionDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionAudioDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,SZPermissionTypeAVAudio);
    }];
}

- (void)getLocationPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    NSError *error = nil;
    if (![CLLocationManager locationServicesEnabled]) {
        error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLocationUnable userInfo:@{NSLocalizedDescriptionKey:@"用户未开启定位设置"}];
        callback(error,SZPermissionTypeLocation);
        return;
    }
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            break;
        case kCLAuthorizationStatusNotDetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLocationNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            break;
        case kCLAuthorizationStatusRestricted:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLocationRestricted userInfo:@{NSLocalizedDescriptionKey:@"用户未获得该权限"}];
            break;
        case kCLAuthorizationStatusDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionLocationDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,SZPermissionTypeLocation);
    }];
}

- (void)getAddressBookPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    NSError *error = nil;
    switch (status) {
        case CNAuthorizationStatusAuthorized:
            break;
        case CNAuthorizationStatusNotDetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionContactsNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            break;
        case CNAuthorizationStatusRestricted:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionContactsRestricted userInfo:@{NSLocalizedDescriptionKey:@"用户未获得该权限"}];
            break;
        case CNAuthorizationStatusDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionContactsDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,SZPermissionTypeContacts);
    }];
}

- (void)getEventKitPermissionType:(SZPermissionType)permissionType
                     withCallback:(SZPermissionTypeCallback)callback
{
    EKEntityType ekType = permissionType == SZPermissionTypeReminder ? EKEntityTypeReminder : EKEntityTypeEvent;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:ekType];
    NSError *error = nil;
    switch (status) {
        case CNAuthorizationStatusAuthorized:
            break;
        case CNAuthorizationStatusNotDetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionEventKitNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            break;
        case CNAuthorizationStatusRestricted:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionEventKitRestricted userInfo:@{NSLocalizedDescriptionKey:@"用户未获得该权限"}];
            break;
        case CNAuthorizationStatusDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionEventKitDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,permissionType);
    }];
}

- (void)getBluetoothPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    CBPeripheralManagerAuthorizationStatus status = CBPeripheralManager.authorizationStatus;
    NSError *error = nil;
    switch (status) {
        case CNAuthorizationStatusAuthorized:
            break;
        case CNAuthorizationStatusNotDetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionBluetoothNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            break;
        case CNAuthorizationStatusRestricted:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionBluetoothRestricted userInfo:@{NSLocalizedDescriptionKey:@"用户未获得该权限"}];
            break;
        case CNAuthorizationStatusDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionBluetoothDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,SZPermissionTypeBluetooth);
    }];
}

- (void)getPushPermissionWithCallback:(SZPermissionTypeCallback)callback
{
    if (@available(iOS 10.0.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            [self dispatchMainCallBack:^{
                NSError *error = nil;
                if (!granted) {
                    error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionPushNotAllow userInfo:@{NSLocalizedFailureReasonErrorKey:@"未获得推送权限"}];
                }
                callback(error,SZPermissionTypePush);
            }];
        }];
    } else {
        UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        NSError *error = nil;
        if (settings.types == UIUserNotificationTypeNone) {
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionPushNotAllow userInfo:@{NSLocalizedDescriptionKey:@"未获得推送权限"}];
        }
        [self dispatchMainCallBack:^{
            callback(error,SZPermissionTypePush);
        }];
    }
}

- (void)getHealthPermissionByObjectType:(id)objectType
                               callback:(SZPermissionTypeCallback)callback
{
    HKHealthStore *store = [[HKHealthStore alloc] init];
    HKAuthorizationStatus status = [store authorizationStatusForType:objectType];
    NSError *error = nil;
    switch (status) {
        case HKAuthorizationStatusSharingAuthorized:
            break;
        case HKAuthorizationStatusNotDetermined:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionHealthNotDetermined userInfo:@{NSLocalizedDescriptionKey:@"用户未明确授权"}];
            break;
        case HKAuthorizationStatusSharingDenied:
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:SZPermissionHealthDenied userInfo:@{NSLocalizedDescriptionKey:@"用户明确拒绝授权"}];
            break;
        default:
            break;
    }
    [self dispatchMainCallBack:^{
        callback(error,SZPermissionTypeHealth);
    }];
}

- (void)dispatchMainCallBack:(dispatch_block_t)callback
{
    if ([NSThread currentThread].isMainThread) {
        callback();
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            callback();
        });
    }
}

@end
