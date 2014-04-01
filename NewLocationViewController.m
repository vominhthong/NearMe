//
//  NewLocationViewController.m
//  NearMeAppT3H
//
//  Created by MC372 on 5/30/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//
#import "NewLocationViewController.h"
#import "ListViewCell.h"
#import "ListViewController.h"

@interface NewLocationViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,GoogleMapAPIServiceDelegate>
@property (retain, nonatomic) IBOutlet UINavigationItem *navigation;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (nonatomic,retain) NSMutableArray *arrayData;
@property (retain, nonatomic) IBOutlet UISearchBar *seachBar;
@property (nonatomic,retain) GoogleMapAPI *googleMapAPI;
@property (nonatomic,retain) NSDictionary *curDicTouched;


@end

@implementation NewLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
          }
    return self;
}
-(void)backToMain{
    [self dismissModalViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - resultGoogleServiceGEOCODING
-(void)resultJSONFromGoogleGeocodeAPI:(NSDictionary *)dict{
    if ([[dict objectForKey:@"status"]isEqualToString:@"OK"]) {
        //rescognize data location finded
        NSArray *arrarDict = [dict objectForKey:@"results"];
        for (NSDictionary *curDic in arrarDict) {
            NSDictionary *dicData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [curDic objectForKey:@"formatted_address"],@"address"
                                     ,[[curDic objectForKey:@"geometry"]objectForKey:@"location" ],@"location", nil];
            [self.arrayData addObject:dicData];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }
}
#pragma mark - SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    NSLog(@"%@",[searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    /*
     http://maps.googleapis.com/maps/api/geocode/json?address=
     */
    NSString *requestLocationTOServiceGeocoding = [NSString stringWithFormat:@"%@%@&sensor=false",GOOGLE_GEOCODE,searchBar.text];
    [self.googleMapAPI geocodeAPIRequestWithURLString:[requestLocationTOServiceGeocoding stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] andID:2];
    
}// called when keyboard search button pressed

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.googleMapAPI = [[GoogleMapAPI alloc]init];
    self.googleMapAPI.delegate = self;
    //Rescognize ArrayInfo Firsts
    self.arrayData = [NSMutableArray array];
    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Current Location",@"address",self.latLng,@"location", nil];
    [self.arrayData addObject:dicInfo];
    //Navigation right location button
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor yellowColor]; // change this color
    
    self.navigation.titleView = label;
    label.text = NSLocalizedString(@"New Location", @"");
    [label sizeToFit];

    //Navigation Back item
    UIImage* locationImage = [UIImage imageNamed:@"back_button.png"];
    
    CGRect frameLocation = CGRectMake(0, 0, locationImage.size.width, locationImage.size.height);
    UIButton *buttonCustom = [[UIButton alloc] initWithFrame:frameLocation];
    [buttonCustom setImage:locationImage forState:UIControlStateNormal];
    
    [buttonCustom addTarget:self action:@selector(backToMain)
           forControlEvents:UIControlEventTouchUpInside];
    //    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *locationBar =[[UIBarButtonItem alloc] initWithCustomView:buttonCustom];

    self.navigation.leftBarButtonItem=locationBar;
    [buttonCustom release];
    
    
    //Navigation Delete History Item
    UIImage* trashButton = [UIImage imageNamed:@"trash_button.png"];
    CGRect frameTrash = CGRectMake(0, 0,trashButton.size.width , trashButton.size.height);
    UIButton *buttonTrash = [[UIButton alloc] initWithFrame:frameTrash];
    [buttonTrash setImage:trashButton forState:UIControlStateNormal];
    
    [buttonTrash addTarget:self action:@selector(backToMain)
           forControlEvents:UIControlEventTouchUpInside];
    //    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *trashBar =[[UIBarButtonItem alloc] initWithCustomView:buttonTrash];
    
    self.navigation.rightBarButtonItem=trashBar;
    [buttonTrash release];

    
    // Set label
    
    self.label.text = @"Selected location :";
    self.indicator.hidesWhenStopped = YES;
    self.indicator.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    [self setSearchIconToFavicon];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}
- (void)setSearchIconToFavicon
{
    // Really a UISearchBarTextField, but the header is private.
    UITextField *searchField = nil;
    for (UIView *subview in self.seachBar.subviews) {
        if ([subview isKindOfClass:[UITextField class]]) {
            searchField = (UITextField *)subview;
            break;
        }
    }
    if (searchField) {
        UIImage *image = [UIImage imageNamed: @"icon_locbar.png"];
        UIImageView *iView = [[UIImageView alloc] initWithImage:image];
        searchField.leftView = iView;
        searchField.placeholder = @"City, Zip Code or Location";
        [iView release];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
   if (indexPath.row == 0) {
       NSDictionary *curLocationInfo = [self.arrayData objectAtIndex:indexPath.row];

        cell.textLabel.text =[curLocationInfo objectForKey:@"address"];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:18];
    }
    if (self.arrayData.count >1) {
        NSDictionary *curLocationInfo = [self.arrayData objectAtIndex:indexPath.row];
        cell.textLabel.text =[curLocationInfo objectForKey:@"address"];
        cell.textLabel.font = [UIFont fontWithName:@"AppleGothic" size:15];
//        CGFloat _height = 0;
        //find out the size for your text. Instead of 255 insert the width of your label
//        CGSize _textSize = [[curLocationInfo objectForKey:@"address"] sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:(CGSize) { 255, 9999 }];
        //add the height of that CGSize variable to your height in case you will need to add more values
//        _height += _textSize.height;
//        self.tableView.rowHeight = _height;

    }
   

    
    
    

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.curDicTouched = [self.arrayData objectAtIndex:indexPath.row];
    //writeData
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:NEWLOCATION]) {
        NSFileHandle *fileHandle =[NSFileHandle fileHandleForWritingAtPath:NEWLOCATION];
        [fileHandle seekToEndOfFile];
        NSData *dataFile =[NSJSONSerialization dataWithJSONObject:self.curDicTouched options:NSJSONWritingPrettyPrinted error:nil];
        [fileHandle writeData:dataFile];
    }
    [self dismissModalViewControllerAnimated:YES];
    
    
}


#pragma mark - setDataEqualToRow
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == tableView.numberOfSections - 1) {
        return [UIView new];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == tableView.numberOfSections - 1) {
        return 1;
    }
    return 0;
}

- (void)dealloc {
    [_label release];
    [_indicator release];
    [_seachBar release];
    [_tableView release];
    [_navigation release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLabel:nil];
    [self setIndicator:nil];
    [self setSeachBar:nil];
    [self setTableView:nil];
    [self setNavigation:nil];
    [super viewDidUnload];
}
@end
