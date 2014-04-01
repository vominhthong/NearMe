//
//  DirectionViewController.h
//  AppASIHTTPRequestDemo
//
//  Created by NTT on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "MapKit/MapKit.h"
@interface DirectionViewController : BaseViewController {
}
@property (retain, nonatomic) IBOutlet UINavigationItem *navigations;
@property(nonatomic, retain) id<MKAnnotation> source;
@property(nonatomic, retain) id<MKAnnotation> destination;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) MKPolyline *routeLine;
@property (nonatomic,retain) NSMutableDictionary *sourceAndDes;
@end
