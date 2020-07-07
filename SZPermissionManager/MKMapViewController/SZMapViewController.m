//
//  SZMapViewController.m
//  SZPermissionManager
//
//  Created by 何松泽 on 2019/8/2.
//  Copyright © 2019 HSZ. All rights reserved.
//

#import "SZMapViewController.h"
#import <MapKit/MapKit.h>

static const CGFloat resetBtnRadius = 80.f;

@interface SZMapViewController ()<MKMapViewDelegate>

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *resetLocation;
@property (nonatomic, strong) MKMapView *mapView;

@property (nonatomic, assign) BOOL isFirstTimeUpdate;
@property (nonatomic, copy) void (^calllback)(CLLocationCoordinate2D coordinate2D);

@end

@implementation SZMapViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initParam];
    }
    return self;
}

- (instancetype)initWithUserLocation:(BOOL)isUserLocation
                            callback:(void(^)(CLLocationCoordinate2D coordinate2D))callback
{
    self = [super init];
    if (self) {
        [self initParam];
        self.isUserLocation = isUserLocation;
        self.calllback = callback;
    }
    return self;
}

- (void)initParam
{
    _longitudeSpan = 0.02;
    _latitudeSpan  = 0.02;
    _isUserLocation = YES;
    _isFirstTimeUpdate = YES;
    /** 默认坐标 北京 */
    _coordinate2D = CLLocationCoordinate2DMake(39.915352,116.397105);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.resetLocation];
}

- (void)backLastedVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetStartLocation
{
    if (_isUserLocation) {
        self.coordinate2D = self.mapView.userLocation.coordinate;
    }else {
        [self.mapView setCenterCoordinate:_coordinate2D animated:YES];
    }
}

#pragma mark - MKMapView Delegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_isFirstTimeUpdate) {
        _isFirstTimeUpdate = NO;
        self.coordinate2D = userLocation.coordinate;
        if (self.calllback) {
            self.calllback(_coordinate2D);
        }
    }
}

#pragma mark - Setter
- (void)setLongitudeSpan:(double)longitudeSpan
{
    _longitudeSpan = longitudeSpan;
    
    MKCoordinateSpan span=MKCoordinateSpanMake(_latitudeSpan, longitudeSpan);
    [self.mapView setRegion:MKCoordinateRegionMake(_coordinate2D, span) animated:YES];
}

- (void)setLatitudeSpan:(double)latitudeSpan
{
    _latitudeSpan = latitudeSpan;
    
    MKCoordinateSpan span=MKCoordinateSpanMake(latitudeSpan, _longitudeSpan);
    [self.mapView setRegion:MKCoordinateRegionMake(_coordinate2D, span) animated:YES];
}

- (void)setCoordinate2D:(CLLocationCoordinate2D)coordinate2D
{
    _coordinate2D = coordinate2D;
    MKCoordinateSpan span=MKCoordinateSpanMake(_latitudeSpan, _longitudeSpan);
    [self.mapView setRegion:MKCoordinateRegionMake(_coordinate2D, span) animated:YES];
}

- (void)setIsUserLocation:(BOOL)isUserLocation
{
    _isUserLocation = isUserLocation;
    self.mapView.showsUserLocation = isUserLocation;
}

#pragma mark - Getter
- (MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
//        _mapView.userTrackingMode=MKUserTrackingModeFollow;
    }
    return _mapView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.backgroundColor = [UIColor greenColor];
        _backBtn.alpha = 0.6f;
        [_backBtn setFrame:CGRectMake(20, [UIApplication sharedApplication].statusBarFrame.size.height + 20, 30, 30)];
        [_backBtn addTarget:self action:@selector(backLastedVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)resetLocation
{
    if (!_resetLocation) {
        _resetLocation = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetLocation.backgroundColor = [UIColor redColor];
        _resetLocation.alpha = 0.6f;
        [_resetLocation setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 20 - resetBtnRadius, [UIScreen mainScreen].bounds.size.height - 100 - resetBtnRadius, resetBtnRadius, resetBtnRadius)];
        [_resetLocation addTarget:self action:@selector(resetStartLocation) forControlEvents:UIControlEventTouchUpInside];
        [_resetLocation setTitle:@"回到原点" forState:UIControlStateNormal];
    }
    return _resetLocation;
}

@end
