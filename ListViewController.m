//
//  ListViewController.m
//  NearMeT3H
//
//  Created by MC372 on 5/23/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import "ListViewController.h"
#import "ListViewCell.h"
#import "ShowMeOnMapViewController.h"
#import "DetailsLocationNearMeViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "NewLocationViewController.h"
@interface ListViewController ()<LocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,URLConnecDelegate,EGORefreshTableHeaderDelegate>
@property (nonatomic)BOOL reloading;
@property (nonatomic) BOOL isFiltered;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,retain) LocationManger *locationManager;
@property (retain, nonatomic) IBOutlet UILabel *ttMyAddress;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *arrayData;
@property (nonatomic,retain) NSString *ttfMyAddressText;
@property (nonatomic,retain) NSCache *cache;
@property (nonatomic,retain) EGORefreshTableHeaderView * refreshHeaderView;
@property (nonatomic,retain) URLConnectionDataDelegate *urlConnDel;
@end

@implementation ListViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.locationManager startUpdateLocation];
    NSDictionary *jSONNewLocation = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:NEWLOCATION] options:NSJSONReadingMutableContainers error:nil];
    if (jSONNewLocation.count >0) {
        if (![[jSONNewLocation objectForKey:@"address"]isEqualToString:@"Current Location"]) {
            self.ttMyAddress.text = [jSONNewLocation objectForKey:@"address"];
            self.lngLat = [jSONNewLocation objectForKey:@"location"];
            
        }

    }
       else{
        [self.locationManager startUpdateLocation];
        [self.locationManager stopUpdateLocation];
        self.ttMyAddress.text = self.ttfMyAddressText;
    }
    
    
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - LocationManagerDelegate
-(void)resultLocationInfoWithError:(NSError *)error{
    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.tag = 1;
    [alertView show];
}
-(void)resultXMLFromBookStoreService:(id)dict{
    if ([self.indicator isAnimating]) {
        [self.indicator stopAnimating];
        self.ttMyAddress.text = dict;
        self.ttfMyAddressText = dict;
    }
}
-(void)resultLocationInfo:(CLLocationCoordinate2D)coordinate{
    [self.locationManager stopUpdateLocation];
    /*
     http://maps.googleapis.com/maps/api/geocode/json?address=%f,%f"
     */
    NSString *stringGeocoding = [NSString stringWithFormat:@"%@%f,%f&sensor=false",GOOGLE_GEOCODE,coordinate.latitude,coordinate.longitude];
    NSNumber *latitude = [[NSNumber alloc]initWithFloat:coordinate.latitude];
    NSNumber *longtitude = [[NSNumber alloc]initWithFloat:coordinate.longitude];
    self.lngLat = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"lat",longtitude,@"lng", nil];
    [self.urlConnDel requestStringDownloadService:stringGeocoding andID:1];
    
    

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint curPoint =[[touches anyObject]locationInView:self.view];
    if (CGRectContainsPoint(self.ttMyAddress.frame, curPoint)) {
        ShowMeOnMapViewController *showMap = [[ShowMeOnMapViewController alloc]init];
        showMap.curDic = self.lngLat;
        showMap.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController pushViewController:showMap animated:YES];
    }
}
-(void)newLocation{
    NewLocationViewController *newLocation = [[[NewLocationViewController alloc]init]autorelease];
    newLocation.latLng = self.lngLat;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:NEWLOCATION]) {
        [fileManager removeItemAtPath:NEWLOCATION error:nil];
        [fileManager createFileAtPath:NEWLOCATION contents:nil attributes:nil];
    }
    newLocation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //[self.navigationController pushViewController:newLocation animated:YES];

    [self presentModalViewController:newLocation animated:YES];
    //[self presentViewController:newLocation animated:YES completion:^{
        
    //}];
}
#pragma mark - settingView
-(void)setttingView{
    NSLog(@"OK");
}
#pragma mark- ViewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.lngLat.count >0) {
        self.ttMyAddress.text = [self.lngLat objectForKey:@"address"];
    }
    else{
        
    
    self.ttMyAddress.text = @"Loading...";
    self.indicator.hidesWhenStopped = YES;
    [self.indicator startAnimating ];
    self.queue = [[NSOperationQueue alloc]init];
    
    self.cache = [[NSCache alloc]init];
    self.queue.maxConcurrentOperationCount = 5;
    //Navigation leftbutton setting button
    UIImage* image3 = [UIImage imageNamed:@"settings_button.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(setttingView)
         forControlEvents:UIControlEventTouchUpInside];
//    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *setting =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigationItem.leftBarButtonItem=setting;
    [someButton release];
    
    
    //Navigation right location button
    UIImage* locationImage = [UIImage imageNamed:@"location_button.png"];
    CGRect frameLocation = CGRectMake(0, 0, locationImage.size.width, locationImage.size.height);
    UIButton *buttonCustom = [[UIButton alloc] initWithFrame:frameLocation];
    [buttonCustom setBackgroundImage:locationImage forState:UIControlStateNormal];
    [buttonCustom addTarget:self action:@selector(newLocation)
         forControlEvents:UIControlEventTouchUpInside];
    //    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *locationBar =[[UIBarButtonItem alloc] initWithCustomView:buttonCustom];
    self.navigationItem.rightBarButtonItem=locationBar;
    [buttonCustom release];
    

    
    
//    [self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rounded_table_cell.png"] ]];
    
    
    self.arrayData = [NSMutableArray array];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_nearme.png"]];
    
    //NavigationLeft
    /*
    UIButton* fakeButton = (UIButton *) [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_button"]];
    UIBarButtonItem *fakeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:fakeButton];
    
    self.navigationItem.leftBarButtonItem = fakeButtonItem;
    
    */
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
   NSData *dataFileContent =  [fileManager contentsAtPath:[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"Data.txt" ]];
    NSString *stringFromDataFileContent = [[NSString alloc]initWithData:dataFileContent encoding:NSUTF8StringEncoding];
    NSArray *arrayStringFormStringFile = [stringFromDataFileContent componentsSeparatedByString:@"\n"];
    for (NSString *curData in arrayStringFormStringFile) {
        NSArray *curArrayData = [curData componentsSeparatedByString:@" ### "];
        NSDictionary *dataObject =[NSDictionary dictionaryWithObjectsAndKeys:
                                   [curArrayData objectAtIndex:0],@"Type",
                                   [curArrayData objectAtIndex:1],@"Image",
                                   [curArrayData objectAtIndex:2],@"NameType"
                                   ,[curArrayData objectAtIndex:3],@"Thumb", nil];
        [self.arrayData addObject:dataObject];
    }
    
    
    
    self.locationManager = [[LocationManger alloc]init];
    self.locationManager.delegate = self;
    self.urlConnDel = [[URLConnectionDataDelegate alloc]init];
    self.urlConnDel.delegate = self;
    [self.searchDisplayController.searchBar setPositionAdjustment:UIOffsetMake(-10, 0) forSearchBarIcon:UISearchBarIconBookmark];
    self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
    [self startUpdateLocation];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    }


}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.arrayData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListViewCell";
    ListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSArray *objects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:nil options:nil];
    for (id curObJ in objects) {
        if ([curObJ isKindOfClass:[ListViewCell class]]) {
            cell = (ListViewCell *)curObJ;
        }
    }

    NSDictionary *curLocationInfo = [self.arrayData objectAtIndex:indexPath.row];
    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_indicator_off.png"]];
    cell.imageView.image = [UIImage imageNamed:[curLocationInfo objectForKey:@"Image"]];
    cell.textLabel.text = [curLocationInfo objectForKey:@"NameType"];
    // Configure the cell...
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *curDicTouched = [self.arrayData objectAtIndex:indexPath.row];
    NSMutableArray *arrayDic = [NSMutableArray arrayWithObjects:curDicTouched,self.lngLat, nil];
    DetailsLocationNearMeViewController *detailView = [[DetailsLocationNearMeViewController alloc]init];
    
    detailView.arrayInfo = arrayDic;
    NSFileManager *fileManager = [NSFileManager defaultManager];

   
//    if ([fileManager contentsAtPath:DOCUMENT_PATH_CHECK]) {
    if([fileManager fileExistsAtPath:DOCUMENT_PATH_CHECK]){
        [fileManager removeItemAtPath:DOCUMENT_PATH_CHECK error:nil];
        detailView.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self.navigationController pushViewController:detailView animated:YES];
    }
    
    
}
-(void)startUpdateLocation{
    [self.locationManager startUpdateLocation];
}

#pragma mark - SetupRefreshTable
- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    self.ttMyAddress.text = @"Loading...";

    [self.indicator startAnimating];
    [self performSelector:@selector(startUpdateLocation) withObject:nil afterDelay:2];
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTtMyAddress:nil];
    [self setIndicator:nil];
    [super viewDidUnload];
}
@end
