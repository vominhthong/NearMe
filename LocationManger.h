//
//  LocationManger.h
//  GoogleMapAPIMapKit
//
//  Created by MC372 on 5/8/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
@protocol LocationManagerDelegate<NSObject>
@required
-(void)resultLocationInfo:(CLLocationCoordinate2D)coordinate;
-(void)resultLocationInfoWithError:(NSError *)error;
@end
@interface LocationManger : NSObject
@property (nonatomic,assign)id<LocationManagerDelegate>delegate;
+(LocationManger *)sharedLocationManager;
-(void)startUpdateLocation;
-(void)stopUpdateLocation;
@end
