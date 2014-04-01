//
//  GoogleMapAPI.m
//  GoogleMapAPIMapKit
//
//  Created by MC372 on 5/8/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import "GoogleMapAPI.h"
static GoogleMapAPI *_instance = nil;
@interface GoogleMapAPI()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
@property (nonatomic,retain)NSMutableData *dataRespond;
@property (nonatomic) int idRequest;
@end
@implementation GoogleMapAPI
+(GoogleMapAPI *)shareGoogleMapAPI{
    if (!_instance) {
        _instance = [[GoogleMapAPI alloc]init];
    }
    return _instance;
}
#pragma mark - NSURLConnectionDelagete
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.dataRespond appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.dataRespond setLength:0];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if (self.idRequest == 0) {
        if ([_delegate respondsToSelector:@selector(resultJSONFromGoogleDirectionAPI:)]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.dataRespond options:NSJSONReadingMutableContainers error:nil];
           
                [_delegate resultJSONFromGoogleDirectionAPI:dic];

            
        }
    }
    
    
    if (self.idRequest ==1) {
        if ([_delegate respondsToSelector:@selector(resultJSONFromGoogleDistanceAPI:)]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.dataRespond options:NSJSONReadingMutableContainers error:nil];
            
            
                [_delegate resultJSONFromGoogleDistanceAPI:dic];

            
        }
    }
    if (self.idRequest == 2) {
        if ([_delegate respondsToSelector:@selector(resultJSONFromGoogleGeocodeAPI:)]) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.dataRespond options:NSJSONReadingMutableContainers error:nil];
                [_delegate resultJSONFromGoogleGeocodeAPI:dic];

            
        }

    }
    
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([_delegate respondsToSelector:@selector(resultJSONFromGoogleMapAPIWithError:)]) {
        [_delegate resultJSONFromGoogleMapAPIWithError:error];
    }
}
#pragma mark - 
-(void)requetWithStringURL:(NSString *)string{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    if (conn) {
        self.dataRespond  = [NSMutableData data];
    }
}
-(void)placeSearchAPISearchRequestWithURLString:(NSString *)string andID:(int)curID{
    self.idRequest = curID;
    [self requetWithStringURL:string];
}
-(void)distanceMatrixAPIRequestWithURLString:(NSString *)string andID:(int)curID{
    self.idRequest = curID;
    [self requetWithStringURL:string];
}
-(void)geocodeAPIRequestWithURLString:(NSString *)string andID:(int)curID{
    self.idRequest = curID;
    [self requetWithStringURL:string];
}

@end
