//
//  PlaceLocation.h
//  MapkitDemo
//
//  Created by MC372 on 5/28/13.
//
//

#import <Foundation/Foundation.h>

@interface PlaceLocation : NSObject
{
    
	NSString* name;
	NSString* description;
	double latitude;
	double longitude;
}
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* description;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@end
