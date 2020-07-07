//
//  SZPermissionManager.h
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/7/31.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SZPermissionType) {
    SZPermissionTypeCamera,
    SZPermissionTypeLibrary,
    SZPermissionTypeLocation,
    SZPermissionTypeAVAudio,
    SZPermissionTypeContacts,
    SZPermissionTypeCalender,
    SZPermissionTypeReminder,
    SZPermissionTypeBluetooth,
    SZPermissionTypePush,
    SZPermissionTypeHealth,
};

typedef void(^SZPermissionTypeCallback) (NSError *_Nullable error,SZPermissionType permissionType);

typedef NS_ENUM(NSUInteger, SZPermissionCameraErrorCode) {
    SZPermissionCameraNotDetermined     = 100000,
    SZPermissionCameraRestricted        = 100001,
    SZPermissionCameraDenied            = 100002,
};

typedef NS_ENUM(NSUInteger, SZPermissionLibraryErrorCode) {
    SZPermissionLibraryNotDetermined    = 200000,
    SZPermissionLibraryRestricted       = 200001,
    SZPermissionLibraryDenied           = 200002,
    SZPermissionLibraryFirstDenied      = 200003,
};

typedef NS_ENUM(NSUInteger, SZPermissionLocationErrorCode) {
    SZPermissionLocationNotDetermined   = 300000,
    SZPermissionLocationRestricted      = 300001,
    SZPermissionLocationDenied          = 300002,
    SZPermissionLocationUnable          = 300003,
};

typedef NS_ENUM(NSUInteger, SZPermissionAudioErrorCode) {
    SZPermissionAudioUndetermined       = 400000,
    SZPermissionAudioDenied             = 400001,
};

typedef NS_ENUM(NSUInteger, SZPermissionContactsErrorCode) {
    SZPermissionContactsNotDetermined   = 500000,
    SZPermissionContactsRestricted      = 500001,
    SZPermissionContactsDenied          = 500002,
};

typedef NS_ENUM(NSUInteger, SZPermissionEventKitErrorCode) {
    SZPermissionEventKitNotDetermined   = 600000,
    SZPermissionEventKitRestricted      = 600001,
    SZPermissionEventKitDenied          = 600002,
};

typedef NS_ENUM(NSUInteger, SZPermissionBluetoothErrorCode) {
    SZPermissionBluetoothNotDetermined  = 700000,
    SZPermissionBluetoothRestricted     = 700001,
    SZPermissionBluetoothDenied         = 700002,
};

typedef NS_ENUM(NSUInteger, SZPermissionOtherErrorCode) {
    SZPermissionPushNotAllow            = 800000,
    SZPermissionHardDeviceNotWork       = 800001,
};

typedef NS_ENUM(NSUInteger, SZPermissionHealthErrorCode) {
    SZPermissionHealthDenied            = 900000,
    SZPermissionHealthNotDetermined     = 900001,
};

@interface SZPermissionManager : NSObject

+ (instancetype)shareManager;

/**
 获取权限状态

 @param type 权限类型
 @param callback 回调error值，为nil则表示有权限
 */
- (void)getPermissionByType:(SZPermissionType)type
                   callback:(SZPermissionTypeCallback)callback;

/**
 获取健康数据，由于健康数据类型很多，多数时候我们不需要全部获取，通过objectType获取需要的数据即可

 @param objectType 实际为HKObjectType，赋值需要导入<HealthKit/HealthKit.h>
 */
- (void)getHealthPermissionByObjectType:(id)objectType
                               callback:(SZPermissionTypeCallback)callback;

@end

/*
 务必在info.plist配置privacy，否则在调用相应的功能权限时会Crash
 使用照相(Camera)功能:
    Privacy - Camera Usage Description
 使用HealthKit读数据:
    Privacy - Health Share Usage Description
 使用HealthKit写数据:
    Privacy - Health Update Usage Description
 定位功能:
    Privacy - Location Always Usage Description Privacy
    Privacy - Location When In Use Usage Description
 使用麦克风(Microphone):
    Privacy - Microphone Usage Description
 使用相册功能:
    Privacy - Photo Library Usage Description
 BLE 设备作为外设:
    Privacy - Bluetooth Peripheral Usage Description
 通讯录访问:
    Privacy - Contacts Usage Description
 日历事件访问:
    Privacy - Calendars Usage Description
 媒体库访问:
    Privacy - Media Library Usage Description
 */

NS_ASSUME_NONNULL_END
