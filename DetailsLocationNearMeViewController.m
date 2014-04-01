#import "DetailsLocationNearMeViewController.h"
#import "DetailsCell.h"
#import "ListViewController.h"
#import <MapKit/MapKit.h>
#import "PlaceLocation.h"
#import "PlaceMark.h"
#import "DirectionViewController.h"
#define GOOGLE_KEY_REQUEST @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
#define GOOGLE_KEY_DISTANCE @"https://maps.googleapis.com/maps/api/distancematrix/json?"

@interface DetailsLocationNearMeViewController ()<GoogleMapAPIServiceDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate,EGORefreshTableHeaderDelegate,MKMapViewDelegate>
@property (retain, nonatomic) IBOutlet UIView *viewKhac;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorInLoadMoreLocation;
@property (retain, nonatomic) IBOutlet MKMapView *mapVIew;
@property (retain, nonatomic) IBOutlet UIButton *buttonEvent;
@property (retain, nonatomic) IBOutlet UILabel *lbCountLocation;
@property (retain, nonatomic) IBOutlet UIView *tableViewFooter;
@property (retain, nonatomic) IBOutlet UIView *viewIndicator;
@property (retain, nonatomic) IBOutlet UIView *viewLoading;
@property (retain, nonatomic) IBOutlet UIImageView *imgError;
@property (retain, nonatomic) IBOutlet UILabel *lbError;
@property (retain, nonatomic) IBOutlet UILabel *lbLoading;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *arrayData;
@property (nonatomic,retain) NSMutableArray *arrayDisAndDua;
@property (nonatomic,retain)NSCache *cache;
@property (nonatomic,retain) 	EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic) BOOL reloading;
@property (nonatomic) BOOL viewMKAnnotation;
@property (nonatomic)int detect;
@property (nonatomic,retain) NSDictionary *dicToDistanceAPI;

@property (nonatomic)int radius;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoadView;

 


@property (nonatomic,retain) GoogleMapAPI *googleMapAPI;
@end

@implementation DetailsLocationNearMeViewController



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self performSelector:@selector(requestToGoogleServicePlaceSearchNearBy) withObject:nil afterDelay:2];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
        {
            self.detect = 0;
            
        }
        case 0:{
            self.detect = 0;
            
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - TableFooterLayout
- (IBAction)loadMoreLocation:(id)sender {
    
    self.detect = self.detect + 1;
    if (self.detect == 1) {
        [self requestToGoogleServicePlaceSearchNearBy];
        [self.indicatorInLoadMoreLocation startAnimating];
    }
    else{
        [[[UIAlertView alloc ]initWithTitle:@"Warning" message:@"Please wait service google response" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil]show];
        self.detect = 0;
        
    }
    NSLog(@"%i",self.detect);
    
    
    
}
#pragma mark - resultGoogleDistanceMatrixAPI
-(void)resultJSONFromGoogleDistanceAPI:(NSDictionary *)dict{
    if ([[dict objectForKey:@"status"]isEqualToString:@"OK"]) {
        NSArray *rows = [dict objectForKey:@"rows"];
        NSMutableArray *distanceArray = [NSMutableArray arrayWithArray:rows];
        NSDictionary *curDis = [distanceArray objectAtIndex:0];
        NSArray *dic = [curDis objectForKey:@"elements"];
        NSDictionary *dics = [dic objectAtIndex:0];
        
        NSString *distance = [[dics objectForKey:@"distance"]objectForKey:@"text"];
        NSString *duration = [[dics objectForKey:@"duration"]objectForKey:@"text"];
        NSDictionary *dicFin = [NSDictionary dictionaryWithObjectsAndKeys:
                                
                                distance,@"dis",
                                duration,@"dua",nil];
        [self.arrayDisAndDua addObject:dicFin];
        if ((self.arrayData.count - self.arrayDisAndDua.count) == 0) {
            if (self.indicatorInLoadMoreLocation.isAnimating) {
                [self.indicatorInLoadMoreLocation stopAnimating];
                
                self.detect = 0;
            }
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
        }
    }
}
#pragma mark - requestGoogleDistanceMatrixAPI
-(void)requetGoogleDistanceMaxtrixAPI{
    /*
     https://maps.googleapis.com/maps/api/distancematrix/json?origins=%@,%@&destinations=%@,%@&mode=driving&sensor=false
     */
    NSString *requestDistanceMaxtrix = [NSString stringWithFormat:@"%@origins=%@,%@&destinations=%@,%@&mode=driving&sensor=false",GOOGLE_KEY_DISTANCE,[[self.arrayInfo objectAtIndex:1]objectForKey:@"lat" ],[[self.arrayInfo objectAtIndex:1]objectForKey:@"lng" ],[self.dicToDistanceAPI objectForKey:@"lat"],[self.dicToDistanceAPI objectForKey:@"lng"]];
    
    NSLog(@"requestDistanceMatrixString : %@",requestDistanceMaxtrix);
    NSLog(@"-----------------------------------------");
    [self.googleMapAPI distanceMatrixAPIRequestWithURLString:requestDistanceMaxtrix andID:1];
    
}
#pragma mark - ResultOfPlaceSearchNearBy
-(void)resultJSONFromGoogleDirectionAPI:(NSDictionary *)dict{
    
    if ([[dict objectForKey:@"status"]isEqualToString:@"OK"]) {
        NSArray *result = [dict objectForKey:@"results"];
        if ([self.indicatorLoadView isAnimating]||[self.indicatorLoadView isHidden]) {
            
            [self.indicatorLoadView stopAnimating];
            self.viewLoading.hidden = YES;
            self.viewIndicator.hidden = YES;
            for (int i =0; i<result.count; i++) {
                
                NSString *curLatCheck = [self.cache objectForKey:@"lat"];
                NSString *latSave = [[result objectAtIndex:i]objectForKey:@"id"];
                self.dicToDistanceAPI = [NSDictionary dictionaryWithObjectsAndKeys:[[[[result objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location" ]objectForKey:@"lat" ],@"lat",[[[[result objectAtIndex:i]objectForKey:@"geometry"]objectForKey:@"location" ]objectForKey:@"lng" ],@"lng", nil];
                
                NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"CheckString.txt"];
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:documentPath];
                NSString *curLat = [[NSString alloc]initWithContentsOfFile:documentPath encoding:NSUTF8StringEncoding error:nil];
                
                NSRange range = [curLat rangeOfString:latSave];
                
                if (!(range.location != NSNotFound) || (curLatCheck == nil)) {
                    
                    NSDictionary *curDic = [NSDictionary dictionaryWithObjectsAndKeys:[[result objectAtIndex:i]objectForKey:@"name" ],@"name",[[result objectAtIndex:i]objectForKey:@"vicinity" ],@"vicinity",[[[[result objectAtIndex:i] objectForKey:@"geometry"]objectForKey:@"location" ]objectForKey:@"lat" ],@"lat",[[[[result objectAtIndex:i] objectForKey:@"geometry"]objectForKey:@"location" ]objectForKey:@"lng" ],@"lng", nil];
                    NSString *saveLat = [NSString stringWithFormat:@"\n%@",[[result objectAtIndex:i]objectForKey:@"id"]];
                    NSData *data = [saveLat dataUsingEncoding:NSUTF8StringEncoding];
                    [self.cache setObject:saveLat forKey:@"lat"];
                    [fileHandle seekToEndOfFile];
                    [fileHandle writeData:data];
                    [fileHandle closeFile];
                    [self requetGoogleDistanceMaxtrixAPI];
                    [self.arrayData addObject:curDic];
                    self.lbCountLocation.text = [NSString stringWithFormat:@"Loaded %i Location in %i Km ",[self.arrayData count],self.radius/500];
                    }
                else{
                    if (result.count ==1 && (range.location != NSNotFound)) {
                        [self creasingRadius];
                    }
                }
            }
        }
    }
    else{
        [self creasingRadius];
    }
}
#pragma mark - CreasingRadius
-(void)creasingRadius{
    int increaseRadius = 500;
    self.radius += increaseRadius;
    self.lbCountLocation.text = [NSString stringWithFormat:@"Loaded %i Location in %i Km ",[self.arrayData count],self.radius/500];
    if (self.radius <=500000) {
        [self requestToGoogleServicePlaceSearchNearBy];
        
    }
    else{
        
    }
}
#pragma mark - ERRORConnection
-(void)resultJSONFromGoogleMapAPIWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"ERROR" message:error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag =1;
    [alert show];
    self.radius = 500; //reset radius.
    
    self.viewLoading.hidden = YES;
    
}
#pragma mark - HandleTouchOFUserInLoadMoreLocation
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint curPointImgErro =[[touches anyObject]locationInView:self.viewIndicator];
    if (CGRectContainsPoint(self.imgError.frame, curPointImgErro)) {
        
        [self requestToGoogleServicePlaceSearchNearBy];
        NSLog(@"OK");
        
    }
    
    
}

#pragma mark - RequestServiceNearBy
-(void)requestToGoogleServicePlaceSearchNearBy{
    /*
     https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f
     
     */
    self.radius +=500;
    NSString *googleServiceDistance = [NSString stringWithFormat:@"%@location=%@,%@&radius=%i&types=%@&sensor=false&key=%@",GOOGLE_KEY_REQUEST,[[self.arrayInfo objectAtIndex:1]objectForKey:@"lat" ],[[self.arrayInfo objectAtIndex:1]objectForKey:@"lng" ],self.radius,[[self.arrayInfo objectAtIndex:0]objectForKey:@"Type" ],GOOGLE_KEY_API];
    [self.googleMapAPI placeSearchAPISearchRequestWithURLString:googleServiceDistance andID:0];
    
}
-(void)makeTextWritingDirectionLeftToRight:(id)sender{
    
}
#pragma mark - showMKAnnotation
-(void)showMKAnnotation{
    NSDictionary *curDicArray = [NSDictionary dictionaryWithObjectsAndKeys:[[self.arrayInfo objectAtIndex:1] objectForKey:@"lat"],@"lat",[[self.arrayInfo objectAtIndex:1] objectForKey:@"lng"],@"lng",@"Current Location",@"name", nil];
    [self.arrayData addObject:curDicArray];
    for (NSDictionary *d in self.arrayData) {
        PlaceLocation* home = [[[PlaceLocation alloc] init] autorelease];
        home.latitude = [[d objectForKey:@"lat"]floatValue];
        home.longitude = [[d objectForKey:@"lng"]floatValue];
		
		PlaceMark *from = [[[PlaceMark alloc] initWithPlace:home] autorelease];
        
		[_mapVIew addAnnotation:from];
        
	}
//    PlaceLocation *home2 = [[[PlaceLocation alloc]init]autorelease];
//    home2.latitude = [[[self.arrayInfo objectAtIndex:1] objectForKey:@"lat"] floatValue];
//    
//    home2.longitude = [[[self.arrayInfo objectAtIndex:1] objectForKey:@"lng"] floatValue];
//    PlaceMark *from2 =[[[PlaceMark alloc]initWithPlace:home2]autorelease];
//    [_mapVIew addAnnotation:from2];
	
	// this method will zoom the map in such a way that all pins will display.
	
    	[self centerMap];
    
}
-(void) centerMap

{
	MKCoordinateRegion region;
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 120;
	CLLocationDegrees minLon = 150;
	NSMutableArray *temp=[NSMutableArray arrayWithArray:self.arrayData];
	NSLog(@"%@",temp);
	for (int i=0; i<[temp count];i++) {
		PlaceLocation* home = [[[PlaceLocation alloc] init] autorelease];
		home.latitude = [[[temp objectAtIndex:i] valueForKey:@"lat"]floatValue];
		home.longitude =[[[temp objectAtIndex:i] valueForKey:@"lng"]floatValue];
		
		PlaceMark* from = [[[PlaceMark alloc] initWithPlace:home] autorelease];
		
		CLLocation* currentLocation = (CLLocation*)from ;
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
		
		region.center.latitude     = (maxLat + minLat) / 2;
		region.center.longitude    = (maxLon + minLon) / 2;
		region.span.latitudeDelta  =  maxLat - minLat;
		region.span.longitudeDelta = maxLon - minLon;
	}
	[_mapVIew setRegion:region animated:YES];
	
}


-(void)makeMKAnnotationMap{

    if (self.viewMKAnnotation == YES || self.viewKhac.isHidden == YES) {
        self.viewKhac.hidden = NO;
        [UIView beginAnimations:@"PartialPageCurlEffect" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        
        [self.view addSubview:self.viewKhac];
        self.viewMKAnnotation = NO;
        
        [UIView commitAnimations];
        [self showMKAnnotation];
        

    }
    else{
        [UIView beginAnimations:@"PartialPageCurlEffect" context:nil];
        [UIView setAnimationDuration:0.3];
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        self.viewMKAnnotation = YES;
        
        [UIView commitAnimations];
      
        self.viewKhac.hidden = YES;

    }
       
    
}
 
#pragma mark - backToViewController
-(void) backToListViewController{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - ViewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewMKAnnotation = YES;
    //Navigation leftbutton setting button
    UIImage* image3 = [UIImage imageNamed:@"back_button.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(backToListViewController)
         forControlEvents:UIControlEventTouchUpInside];
    //    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *setting =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem=setting;
    [someButton release];
    
    //Navigation right button
    UIImage* map = [UIImage imageNamed:@"map_button.png"];
    CGRect frameMap = CGRectMake(0, 0, map.size.width, map.size.height);
    UIButton *mapButton = [[UIButton alloc] initWithFrame:frameMap];
    [mapButton setBackgroundImage:map forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(makeMKAnnotationMap)
         forControlEvents:UIControlEventTouchUpInside];
    //    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *mapSetting =[[UIBarButtonItem alloc] initWithCustomView:mapButton];
    self.navigationItem.rightBarButtonItem=mapSetting;
    [mapButton release];
    
    

    
    
    // Header table Refesh
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    

    

    self.indicatorInLoadMoreLocation.hidesWhenStopped = YES;
    self.detect = 0;
    self.arrayDisAndDua = [NSMutableArray array];
    //Check String in documentPath
    NSString *documentPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject]stringByAppendingPathComponent:@"CheckString.txt"];
    NSString *bundle = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"CheckString.txt"];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if (![fileManger contentsAtPath:documentPath]) {
        [fileManger copyItemAtPath:bundle toPath:documentPath error:nil];
        
    }
    // Declare radius.
    self.tableView.rowHeight = 60;

    self.radius = 1000;
    
    //Add button to footer table View
    self.tableView.tableFooterView = self.tableViewFooter;
    
    // Declare Delegate for main theard;
    self.arrayData = [NSMutableArray array];
    self.googleMapAPI = [[GoogleMapAPI alloc]init];
    self.googleMapAPI.delegate = self;
    self.cache = [[NSCache alloc]init];
    //.[self performSelectorOnMainThread:@selector(requestToGoogleServicePlaceSearchNearBy) withObject:nil waitUntilDone:NO];
//    [self requestToGoogleServicePlaceSearchNearBy];
    self.indicatorLoadView.hidesWhenStopped = YES;
    [self.indicatorLoadView startAnimating];
    self.navigationItem.title = [[self.arrayInfo objectAtIndex:0] objectForKey:@"NameType"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayData count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailsCell";
    DetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:nil options:nil];
    for (id curObJ in objects) {
        if ([curObJ isKindOfClass:[DetailsCell class]]) {
            cell = (DetailsCell *)curObJ;
        }
    }
    
    
    NSDictionary *curDic = [self.arrayData objectAtIndex:indexPath.row];
    NSDictionary *disAndDua = [self.arrayDisAndDua objectAtIndex:indexPath.row];
    
    cell.nameDetails.text = [curDic objectForKey:@"name"];
    cell.addressDetails.text = [curDic objectForKey:@"vicinity"];
    cell.distane.text = [disAndDua objectForKey:@"dis"];
    cell.value.text = [disAndDua objectForKey:@"dua"];
    cell.imageView.image = [UIImage imageNamed:[[self.arrayInfo objectAtIndex:0] objectForKey:@"Thumb"]];
   
        
    
    
    
    return cell;
}


#pragma mark - UITableViewDataSourceDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSMutableDictionary *curDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i",indexPath.row + 1],@"here",[self.arrayData objectAtIndex:indexPath.row],@"total",[NSString stringWithFormat:@"%i",[self.arrayData count]],@"count", nil];
    DirectionViewController *directView = [[[DirectionViewController alloc]init]autorelease];
    directView.sourceAndDes = curDic;
   // [self.navigationController pushViewController:directView animated:YES];
    [self presentModalViewController:directView animated:YES];
}

#pragma mark - SetupRefreshTable
- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    [self performSelector:@selector(requestToGoogleServicePlaceSearchNearBy) withObject:nil afterDelay:2];
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setIndicatorLoadView:nil];
    [self setViewLoading:nil];
    [self setLbLoading:nil];
    [self setLbError:nil];
    [self setImgError:nil];
    [self setViewIndicator:nil];
    [self setTableViewFooter:nil];
    [self setLbCountLocation:nil];
    [self setButtonEvent:nil];
    [self setIndicatorInLoadMoreLocation:nil];
    [self setViewKhac:nil];
    [self setMapVIew:nil];
    [super viewDidUnload];
}
- (void)dealloc {
    [_viewKhac release];
    [_mapVIew release];
    
    [super dealloc];
}
@end
