//
//  LocationManger.m
//  GoogleMapAPIMapKit
//
//  Created by MC372 on 5/8/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import "LocationManger.h"
static LocationManger *_instace = nil;
@interface LocationManger ()<CLLocationManagerDelegate>
@property (nonatomic,retain) CLLocationManager *locationManager;

@end
@implementation LocationManger
+(LocationManger *)sharedLocationManager{
    if (!_instace) {
        _instace = [[LocationManger alloc]init];
    }
    return _instace;
}
-(void)startUpdateLocation{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    if (self.locationManager) {
        [self.locationManager startUpdatingLocation];
    }
}
-(void)stopUpdateLocation{
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
    }
}
#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    if ([_delegate respondsToSelector:@selector(resultLocationInfo:)]) {
        
        [_delegate resultLocationInfo:newLocation.coordinate];
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if ([_delegate respondsToSelector:@selector(resultLocationInfo:)]) {
        [_delegate resultLocationInfo:[[locations objectAtIndex:0]coordinate ]];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([_delegate respondsToSelector:@selector(resultLocationInfoWithError:)]) {
        [_delegate resultLocationInfoWithError:error];
    }
}
@end
