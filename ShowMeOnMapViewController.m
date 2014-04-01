//
//  ShowMeOnMapViewController.m
//  NearMeT3H
//
//  Created by MC372 on 5/24/13.
//  Copyright (c) 2013 MC372. All rights reserved.
//

#import "ShowMeOnMapViewController.h"
#import "Location.h"
@interface ShowMeOnMapViewController ()
@property (retain, nonatomic) IBOutlet MKMapView *myMapView;

@end

@implementation ShowMeOnMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_nearme.png"]];
    Location *location = [[Location alloc]init];
    location.title = @"Nha Be";
    location.subtitle = @"5/13B Huynh Tan Phat, TT Nha Be, HCM";
    float lat  = [[self.curDic objectForKey:@"lat"] floatValue];
    float lng = [[self.curDic objectForKey:@"lng"] floatValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat,lng);
    location.coordinate = coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate,2000, 2000);
    [self.myMapView setRegion:region animated:YES];
    [self.myMapView setNeedsDisplay];
    [self.myMapView addAnnotations:[NSArray arrayWithObjects:location, nil]];

    
    
  }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setMyMapView:nil];
    [super viewDidUnload];
}
@end
