//
//  GoogleMapAPI.h
//  GoogleMapAPIMapKit
//
//  Created by MC372 on 5/8/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol GoogleMapAPIServiceDelegate<NSObject>
@optional
-(void)resultJSONFromGoogleDirectionAPI:(NSDictionary *)dict;
-(void)resultJSONFromGoogleMapAPI:(NSDictionary *)dict;
-(void)resultJSONFromGoogleDistanceAPI:(NSDictionary *)dict;
-(void)resultJSONFromGoogleGeocodeAPI:(NSDictionary *)dict;
-(void)resultJSONFromGoogleMapAPIWithError:(NSError *)error;
@end
@interface GoogleMapAPI : NSObject
@property (nonatomic,assign) id<GoogleMapAPIServiceDelegate>delegate;
+(GoogleMapAPI *)shareGoogleMapAPI;
-(void)placeSearchAPISearchRequestWithURLString:(NSString *)string andID:(int)curID;
-(void)distanceMatrixAPIRequestWithURLString:(NSString *)string andID:(int)curID;
-(void)geocodeAPIRequestWithURLString:(NSString *)string andID:(int) curID;
@end
