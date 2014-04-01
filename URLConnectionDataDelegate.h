#import <Foundation/Foundation.h>
@protocol URLConnecDelegate<NSObject>
@optional
-(void)resultXMLFromBookStoreService:(id)dict;
-(void)resultWithError:(NSString *)error;
@end
@interface URLConnectionDataDelegate : NSObject
@property (nonatomic,assign) id<URLConnecDelegate>delegate;

+(URLConnectionDataDelegate *)shareBookStoreService;
#pragma mark - requsetServiceWithStringNusoapLoadBook
-(void)requestStringDownloadService:(NSString *)string andID:(int)idRequest;
@end
