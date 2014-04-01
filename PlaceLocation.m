//
//  PlaceLocation.m
//  MapkitDemo
//
//  Created by MC372 on 5/28/13.
//
//

#import "PlaceLocation.h"

@implementation PlaceLocation
@synthesize name;
@synthesize description;
@synthesize latitude;
@synthesize longitude;
- (void) dealloc
{
	[name release];
	[description release];
	[super dealloc];
}
@end
