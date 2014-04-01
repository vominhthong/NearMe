 
#import "Place.h"

@implementation Place

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
