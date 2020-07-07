//
//  ViewController.m
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/7/31.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import "ViewController.h"
#import "SZPermissionManager/SZPermissionManager.h"
#import "SZPermissionUtils.h"
#import "SZImageModel.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (int i = 0; i < SZPermissionTypePush+1; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.backgroundColor = [UIColor colorWithRed:(double)(random()%255/255.0) green:(double)(random()%255/255.0) blue:(double)(random()%255/255.0) alpha:1.f];
        [button setFrame:CGRectMake(100, 50*i+100, 100, 40)];
        [button setTitle:@"test" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 500, 300, 200)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
}

- (void)clickEvent:(UIButton *)button
{
    __weak typeof(self)weakSelf = self;
    if (button.tag == SZPermissionTypeLibrary) {
        [[SZLibraryCameraUtils shareUtils] openLibraryBySuperVC:self callback:^(NSError * _Nullable error, NSArray<SZImageModel *> * _Nullable images) {
            if (!error && images.count > 0) {
                [weakSelf.imageView setImage:[images firstObject].originImage];
            }
            NSLog(@"%ld:%@",error.code,error.localizedDescription);
        }];
    }else if (button.tag == SZPermissionTypeCamera) {
        [[SZLibraryCameraUtils shareUtils] openCameraBySuperVC:self callback:^(NSError * _Nullable error, NSArray<SZImageModel *> * _Nullable images) {
            if (!error && images.count > 0) {
                [weakSelf.imageView setImage:[images firstObject].originImage];
            }
            NSLog(@"%ld:%@",error.code,error.localizedDescription);
        }];
    }else if (button.tag == SZPermissionTypeLocation) {
        [[SZLocationUtils shareUtils] openMapViewControllerOnSuperVC:self callback:^(NSError * _Nullable error, CLLocationCoordinate2D coordinate2D) {
            NSLog(@"%f.%f",coordinate2D.latitude,coordinate2D.longitude);
        }];
    }else if (button.tag == SZPermissionTypeAVAudio) {
        [[SZPermissionManager shareManager] getPermissionByType:SZPermissionTypeAVAudio callback:^(NSError * _Nullable error, SZPermissionType permissionType) {
            NSLog(@"%ld:%@",error.code,error.localizedDescription);
        }];
    }
//    [[SZPermissionManager shareManager] getPermissionByType:button.tag callback:^(NSError * _Nullable error,SZPermissionType permissionType) {
//        NSLog(@"%ld:%@",error.code,error.localizedDescription);
//    }];
}

@end
