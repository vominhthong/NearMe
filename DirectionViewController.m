//
//  DirectionViewController.m
//  AppASIHTTPRequestDemo
//
//  Created by NTT on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DirectionViewController.h"
#import "Place.h"
#import "StringHelper.h"
#import "DetailsLocationNearMeViewController.h"
@interface  DirectionViewController()<LocationManagerDelegate,GoogleMapAPIServiceDelegate>
@property (nonatomic,retain) LocationManger *locationManager;
@property(nonatomic) CLLocationCoordinate2D *sourceCLL;
@property (nonatomic,retain) NSString *formatAddress;

@property (nonatomic,retain) GoogleMapAPI *googleMapAPI;
@end


@implementation DirectionViewController
@synthesize map, routeLine;
@synthesize source;
@synthesize destination;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - doSomeThing
- (void) doSomeThing {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Do something!!!" message:@":))" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
    [alert show];
}
#pragma mark - V1
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[Place class]]) {
        
		MKPinAnnotationView* pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
		if (annotation == source) {
			//pin.pinColor = MKPinAnnotationColorGreen;
            
            //Size: 32x29
            UIImageView *image1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"source.jpeg"]] autorelease];
            pin.leftCalloutAccessoryView = image1;
            
            //Size: 30x40
            pin.image = [UIImage imageNamed:@"pin1.png"];
            
		} else {
			//pin.pinColor = MKPinAnnotationColorRed;
            
            //Size: 32x29
            UIImageView *image2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"destination.jpeg"]] autorelease];
            pin.leftCalloutAccessoryView = image2;
            
            //Size: 30x40
            UIImage *pinImage = [UIImage imageNamed:@"pin2.png"];
            pin.image = pinImage;
		}
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [btn addTarget:self action:@selector(doSomeThing) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = btn;
        pin.canShowCallout = YES;
		return [pin autorelease];
	}
	return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id )overlay {
	MKPolylineView* routeLineView = [[[MKPolylineView alloc] initWithPolyline:self.routeLine] autorelease];
	routeLineView.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
	routeLineView.strokeColor = [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f];
	routeLineView.lineWidth = 4;
	return routeLineView;
}
// Decode a polyline.
// See: http://code.google.com/apis/maps/documentation/utilities/polylinealgorithm.html
- (NSMutableArray *)decodePolyLine:(NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
		// printf("[%f,", [latitude doubleValue]);
		// printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
		[array addObject:loc];
	}
	
	return array;
}
#pragma mark -
#pragma mark Directions

- (void) setRoutePoints:(NSArray*)locations {
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * locations.count);
	NSUInteger i, count = [locations count];
	for (i = 0; i < count; i++) {
		CLLocation* obj = [locations objectAtIndex:i];
		MKMapPoint point = MKMapPointForCoordinate(obj.coordinate);
		pointArr[i] = point;
	}
	
	if (routeLine) {
		[map removeOverlay:routeLine];
	}
	
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:locations.count];
	free(pointArr);
	
	[map addOverlay:routeLine];
	
	
	CLLocationDegrees maxLat = -90.0f;
	CLLocationDegrees maxLon = -180.0f;
	CLLocationDegrees minLat = 90.0f;
	CLLocationDegrees minLon = 180.0f;
	
	for (int i = 0; i < locations.count; i++) {
		CLLocation *currentLocation = [locations objectAtIndex:i];
		if(currentLocation.coordinate.latitude > maxLat) {
			maxLat = currentLocation.coordinate.latitude;
		}
		if(currentLocation.coordinate.latitude < minLat) {
			minLat = currentLocation.coordinate.latitude;
		}
		if(currentLocation.coordinate.longitude > maxLon) {
			maxLon = currentLocation.coordinate.longitude;
		}
		if(currentLocation.coordinate.longitude < minLon) {
			minLon = currentLocation.coordinate.longitude;
		}
	}
	
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[map setRegion:region animated:YES];
}

- (void)drawRoute:(NSMutableDictionary *)response
{
	NSMutableArray* coordinates = [response objectForKey:@"coordinates"];
	
	NSMutableArray* aux = [[NSMutableArray alloc] initWithCapacity:[coordinates count]];
	for (NSMutableDictionary* dict in coordinates)
	{
		NSNumber* lat = [dict objectForKey:@"lat"];
		NSNumber* lon = [dict objectForKey:@"lon"];
		
		CLLocation* location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
		[aux addObject:location];
		[location release];
	}
	
	[self setRoutePoints:aux];
	[aux release];
}
- (void)calculateDirectionsFinished:(ASIHTTPRequest *)request {
	@try {
		NSString* responseString = [request responseString];
        
        NSLog(@"%@", responseString);
        // TODO: better parsing. Regular expression?
        
		NSInteger a = [responseString indexOf:@"points:\"" from:0];
		NSInteger b = [responseString indexOf:@"\",levels:\"" from:a] - 10;
		
		NSInteger c = [responseString indexOf:@"tooltipHtml:\"" from:0];
		NSInteger d = [responseString indexOf:@"(" from:c];
		NSInteger e = [responseString indexOf:@")\"" from:d] - 2;
		
		NSString* info = [[responseString substringFrom:d to:e] stringByReplacingOccurrencesOfString:@"\\x26#160;" withString:@""];
        NSLog(@"tooltip %@", info);
		
		NSString* encodedPoints = [responseString substringFrom:a to:b];
		NSArray* steps = [self decodePolyLine:[encodedPoints mutableCopy]];
		if (steps && [steps count] > 0) {
			[self setRoutePoints:steps];
			//} else if (!steps) {
			//	[self showError:@"No se pudo calcular la ruta"];
		} else {
			// TODO: show error
		}
	}
	@catch (NSException * e) {
        // TODO: show error
	}
}
- (void)calculateDirectionsFailed:(ASIHTTPRequest *)request {
    // TODO: show error
}
- (void)calculateDirections {
	CLLocationCoordinate2D f = source.coordinate;
	CLLocationCoordinate2D t = destination.coordinate;
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	
	NSString* s = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@&hl=%@", saddr, daddr, [[NSLocale currentLocale] localeIdentifier]];
    // by car:
    // s = [s stringByAppendingFormat:@"&dirflg=w"];
	
	ASIHTTPRequest *req = [self requestWithURL:s];
	[req setDidFinishSelector:@selector(calculateDirectionsFinished:)];
	[req setDidFailSelector:@selector(calculateDirectionsFailed:)];
	[req startAsynchronous];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
   // [self.locationManager startUpdateLocation];
    //Rescognize Source
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}
-(void)resultJSONFromGoogleGeocodeAPI:(NSDictionary *)dict{
    /*
        "formatted_address" = "1 Stockton Street, San Francisco, CA 94108, USA";
     */
    if ([[dict objectForKey:@"status"]isEqualToString:@"OK"]) {
           self.formatAddress =  [[[dict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"formatted_address"];
    }

    
    
    
}
-(void)resultLocationInfo:(CLLocationCoordinate2D)coordinate{
    [self.locationManager stopUpdateLocation];

    
    // Regsconize Source

    Place* a = [[[Place alloc] init] autorelease];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [fileManager contentsAtPath:NEWLOCATION];
    
    NSDictionary *newLocation = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (newLocation.count >0) {
        a.title = [newLocation objectForKey:@"address"];
        a.coordinate = CLLocationCoordinate2DMake([[[newLocation objectForKey:@"location"]objectForKey:@"lat"] floatValue], [[[newLocation objectForKey:@"location"]objectForKey:@"lng"] floatValue]);

    }
    else{
        a.coordinate = coordinate;

    }
    
    //Regcognize Des
    Place* b = [[[Place alloc] init] autorelease];
    b.title = [[self.sourceAndDes objectForKey:@"total"]objectForKey:@"name" ];
    b.subtitle = [[self.sourceAndDes objectForKey:@"total"] objectForKey:@"vicinity"];
    b.coordinate = CLLocationCoordinate2DMake([[[self.sourceAndDes objectForKey:@"total" ] objectForKey:@"lat" ]floatValue ], [[[self.sourceAndDes objectForKey:@"total"] objectForKey:@"lng" ] floatValue]);

    self.source = a;
    self.destination = b;
    
    [map addAnnotation:a];
    [map addAnnotation:b];
    
    [a release];
    [b release];
        
    [self calculateDirections];


}

-(void)resultLocationInfoWithError:(NSError *)error{
    [[[UIAlertView alloc]initWithTitle:@"ERROR" message:error.localizedDescription delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil]show];
}
#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */
-(void)refreshMap{
    [self.locationManager startUpdateLocation];
}
-(void)back{

    [self dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ OF %@",[NSString stringWithFormat:@"%@",[self.sourceAndDes objectForKey:@"here"]],[NSString stringWithFormat:@"%@",[self.sourceAndDes objectForKey:@"count"]]];
    self.locationManager = [[LocationManger alloc]init];
    self.locationManager.delegate = self;
    
    self.googleMapAPI = [[GoogleMapAPI alloc]init];
    self.googleMapAPI.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshMap)];
    
    //Navigation leftbutton setting button
    UIImage* image3 = [UIImage imageNamed:@"back_button.png"];
    CGRect frameimg = CGRectMake(0, 0, image3.size.width, image3.size.height);
    UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
    [someButton setBackgroundImage:image3 forState:UIControlStateNormal];
    [someButton addTarget:self action:@selector(back)
         forControlEvents:UIControlEventTouchUpInside];
    //    [someButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *setting =[[UIBarButtonItem alloc] initWithCustomView:someButton];
    self.navigations.leftBarButtonItem=setting;
    [someButton release];
    self.navigations.title = @"Google MAP";
    

    
    [self.locationManager startUpdateLocation];
}


- (void)viewDidUnload
{
    [self setNavigations:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_navigations release];
    [super dealloc];
}
@end
