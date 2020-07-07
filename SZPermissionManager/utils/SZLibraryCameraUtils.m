//
//  SZLibraryCameraUtils.m
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/1.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import "SZLibraryCameraUtils.h"
#import "SZPermissionManager.h"
#import <Photos/Photos.h>
#import "SZImageModel.h"

@interface SZLibraryCameraUtils()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *pickerController;
@property (nonatomic, strong) NSMutableArray<SZImageModel *> *imagesArr;
@property (nonatomic, copy) void (^selectedCallback)(NSError *_Nullable error,NSArray<UIImage *> *_Nullable images);

@end

@implementation SZLibraryCameraUtils

+ (instancetype)shareUtils
{
    static SZLibraryCameraUtils *_utils = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utils = [[SZLibraryCameraUtils alloc] init];
        _utils.pickerController = [[UIImagePickerController alloc] init];
        _utils.pickerController.editing = YES;
        _utils.imagesArr = [[NSMutableArray alloc] init];
    });
    return _utils;
}

- (void)openLibraryBySuperVC:(UIViewController *)superVC
                    callback:(nullable SZLiraryCallback)callback
{
    __weak typeof(self)weakSelf = self;
    self.selectedCallback = callback;
    [[SZPermissionManager shareManager] getPermissionByType:SZPermissionTypeLibrary callback:^(NSError * _Nullable error, SZPermissionType permissionType) {
        if (error.code == SZPermissionLibraryFirstDenied || error.code == SZPermissionHardDeviceNotWork) {
            //第一次拒绝授权
            if (callback) {
                callback(error,nil);
            }
        }else if (error.code == SZPermissionLibraryNotDetermined) {
            // 未明确授权不做操作，反馈完成
        }else if (error.code == SZPermissionLibraryDenied || error.code == SZPermissionLibraryRestricted) {
            [weakSelf dispatchMainCallBack:^{
                // 再次询问：此前询问过用户而被用户拒绝了 || 用户无权限
                [weakSelf showOpenPrivacyAlertTitle:@"需要访问您的相册权限" message:nil BySuperVC:superVC];
                if (callback) {
                    callback(error,nil);
                }
            }];
        }else {
            [weakSelf dispatchMainCallBack:^{
                [weakSelf showPickerViewControllerType:SZPermissionTypeLibrary bySuperVC:superVC];
            }];
        }
    }];
}

- (void)openCameraBySuperVC:(UIViewController *)superVC
                   callback:(nullable SZLiraryCallback)callback
{
    __weak typeof(self)weakSelf = self;
    self.selectedCallback = callback;
    [[SZPermissionManager shareManager] getPermissionByType:SZPermissionTypeCamera callback:^(NSError * _Nullable error, SZPermissionType permissionType) {
        [weakSelf dispatchMainCallBack:^{
            if (error.code == SZPermissionCameraDenied) {
                // 此前询问过用户而被用户拒绝了，再次询问
                [weakSelf showOpenPrivacyAlertTitle:@"需要访问您的拍照权限" message:nil BySuperVC:superVC];
                callback(error,nil);
            } else if (error.code == SZPermissionHardDeviceNotWork) {
                if (callback) {
                    callback(error,nil);
                }
            }else {
                [weakSelf showPickerViewControllerType:SZPermissionTypeCamera bySuperVC:superVC];
            }
        }];
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

- (void)showPickerViewControllerType:(SZPermissionType)type
                           bySuperVC:(UIViewController *)superVC
{
    UIImagePickerControllerSourceType sourceType = type == SZPermissionTypeCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    [self.imagesArr removeAllObjects];
    self.pickerController.delegate = self;
    self.pickerController.sourceType = sourceType;
    [superVC presentViewController:self.pickerController animated:YES completion:nil];

}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_selectedCallback) {
        _selectedCallback(nil, nil);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *originImage = info[UIImagePickerControllerOriginalImage];
    SZImageModel *imageModel = [SZImageModel new];
    imageModel.originImage = originImage;
    [_imagesArr addObject:imageModel];
    if (_selectedCallback) {
        _selectedCallback(nil, [_imagesArr copy]);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Method
- (void)dispatchMainCallBack:(dispatch_block_t)callback
{
    if ([NSThread currentThread].isMainThread) {
        if (callback) {
            callback();
        }
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback();
            }
        });
    }
}

@end
