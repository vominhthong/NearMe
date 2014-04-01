
#import "URLConnectionDataDelegate.h"
static URLConnectionDataDelegate *_instance = nil;
@interface URLConnectionDataDelegate() <NSURLConnectionDataDelegate,NSURLConnectionDelegate>
@property (nonatomic,retain) NSMutableData *dataRespond;
@property (nonatomic,retain) UIRefreshControl *refreshControl;
@property (nonatomic,retain) NSString *action;
@property (nonatomic,retain) NSCache *cache;
@property (nonatomic) int curID;

@end
@implementation URLConnectionDataDelegate
+(URLConnectionDataDelegate *)shareBookStoreService{
    if (!_instance) {
        _instance = [[URLConnectionDataDelegate alloc]init];
        
    }
    return _instance;
}
#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
        [self.dataRespond appendData:data];

    

    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    response = [self.cache objectForKey:@"respond"];

        [self.dataRespond setLength:0];
       
 

}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (self.curID == 1) {
            if ([_delegate respondsToSelector:@selector(resultXMLFromBookStoreService:)]) {
            
                NSDictionary *curDic = [NSJSONSerialization JSONObjectWithData:self.dataRespond options:NSJSONReadingMutableContainers error:nil];
                if ([[curDic objectForKey:@"status"]isEqualToString:@"OK"]) {
                    
                    NSString *addressFakeArray = [[[curDic objectForKey:@"results"]objectAtIndex:0]objectForKey:@"formatted_address"];
                    

                    [_delegate resultXMLFromBookStoreService:addressFakeArray];
                    
                }
            
            
        }
        if (self.curID == 2) {
            NSLog(@"OK");
        }
    }

    

}
#pragma mark - NSURLConnectionDelegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([_delegate respondsToSelector:@selector(resultWithError:)]) {
        
        [_delegate resultWithError:error.localizedDescription];
    }

}

#pragma mark - RequestStringToDownloadSomeThing
-(void)requetStringWithURL:(NSString *)string{
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    if (conn) {
        self.dataRespond = [NSMutableData data];
    }
}
#pragma mark - RequestStringToDownloadWithURL

-(void)requestStringDownloadService:(NSString *)string andID:(int)idRequest{

    self.curID = idRequest;
    [self requetStringWithURL:string];
}


@end
