//
//  Location.h
//  GoogleMapAPIMapKit
//
//  Created by MC372 on 5/13/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
@interface Location : NSObject<MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@end
