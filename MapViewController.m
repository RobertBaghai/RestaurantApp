//
//  MapViewController.m
//  RestaurantApp
//
//  Created by Robert Baghai on 5/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

#import "MapViewController.h"
#import "Constants.h"
#import "CustomMarker.h"
#import "AnnotationView.h"
#import "Place.h"
@import GoogleMaps;

@interface MapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate>

@property (nonatomic, strong) NSMutableArray   *arrayOfSearchMarkers;
@property (nonatomic, strong) NSDictionary     *dictionaryOfSearchResults;
@property (nonatomic, strong) NSDictionary     *dicitonaryOfPlaceResults;
@property (nonatomic, strong) NSDictionary     *dictionaryOfPlaceSearchResults;
@property (nonatomic, strong) NSString         *placeToSearch;
@property (nonatomic, strong) Place            *placeInfo;

/*
 *hard coded for now
 *represents a users search
 *replace later on with search textField.text
 */
@property (nonatomic, strong) NSString *userTextSearch;
//

#pragma mark - Location
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


#pragma mark - UI
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userTextSearch = @"Chiptole";
    
    [self getCurrentLocation];
    self.mapView.delegate                  = self;
    self.mapView.myLocationEnabled         = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.compassButton    = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GMSMapView Delegate
- (UIView*)mapView:(GMSMapView*)mapView markerInfoWindow:(CustomMarker*)marker {
    AnnotationView *infoWindow        = [[[NSBundle mainBundle]loadNibNamed:@"AnnotationView" owner:self options:nil]objectAtIndex:0];
    infoWindow.titleLabel.text        = marker.title;
    infoWindow.subTitleLabel.text     = marker.snippet;
    infoWindow.imageView.image        = marker.image;
    return infoWindow;
}

- (void)mapView:(GMSMapView*)mapView didTapInfoWindowOfMarker:(CustomMarker*)marker {
    self.placeToSearch = marker.placeId;
    NSLog(@"PLACE ID == %@",self.placeToSearch);
    [self performSegueWithIdentifier:kPlaceDetailSegue sender:nil];
    //fetch info for selected place using it's id... API Request for place id
}

#pragma mark - Location
- (void)getCurrentLocation {
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocation Manager Delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    self.coordinate = location.coordinate;
    NSLog(@"Latitude = %f, Longitude = %f",self.coordinate.latitude, self.coordinate.longitude);
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude zoom:15];
    
    //fetch places based on user search input.. API Request for places in a certain radius
    //then can stop updating locations..
    [self fetchPlacesBasedOnUserSearch];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    //temporary
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    #warning show error message
    NSLog(@"Error = %@, %@", error.localizedDescription, error.userInfo);
    //present alert to user
}


#pragma mark - Lazy Instantiation
-(CLLocationManager*)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (NSMutableArray *)arrayOfSearchMarkers {
    if (!_arrayOfSearchMarkers) {
        _arrayOfSearchMarkers = [[NSMutableArray alloc] init];
    }
    return _arrayOfSearchMarkers;
}

#pragma mark - API Requests
- (void)fetchPlacesBasedOnUserSearch {
    NSLog(@"Latitude = %f, Longitude = %f",self.coordinate.latitude, self.coordinate.longitude);

    NSURLSession *session = [NSURLSession sharedSession];
    NSURL        *url     = [NSURL URLWithString:[NSString stringWithFormat
                                                  :@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%lf,%lf&radius=8000&keyword=%@&key=%@",
                                                  self.coordinate.latitude,
                                                  self.coordinate.longitude,
                                                  self.userTextSearch,
                                                  kServerKey
                                                  ]];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data,
                                                      NSURLResponse * _Nullable response,
                                                      NSError * _Nullable error) {
        if ( error ) {
            #warning show error message
            NSLog(@"Error : %@, %@",error.localizedDescription, error.userInfo);
        } else {
            dispatch_async(dispatch_get_main_queue(),^{
                self.dictionaryOfSearchResults = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //                NSLog(@"%@",self.dictionaryOfSearchResults);
                [self parseAndPin];
            });
        }
    }] resume];
}

- (void)parseAndPin {
    NSDictionary *result    = [self.dictionaryOfSearchResults objectForKey:@"results"];
    NSDictionary *tempGeo   = [result valueForKey:@"geometry"];
    NSDictionary *tempLoc   = [tempGeo valueForKey:@"location"];
    NSArray *nameArray      = [result valueForKey:@"name"];
    NSArray *iconArray      = [result valueForKey:@"icon"];
    NSArray *latitudeArray  = [tempLoc valueForKey:@"lat"];
    NSArray *longitudeArray = [tempLoc valueForKey:@"lng"];
    NSArray *place_idArray =  [result valueForKey:@"place_id"];
    
    for (int i = 0 ; i < latitudeArray.count; i++) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[latitudeArray objectAtIndex:i] doubleValue]
                                                                longitude:[[longitudeArray objectAtIndex:i] doubleValue] zoom:12];
        NSString *string = [NSString stringWithFormat:@"%@",[iconArray objectAtIndex:i]];
        
        CustomMarker *searchMarker = [[CustomMarker alloc] init];
        searchMarker.position      = camera.target;
        searchMarker.title         = [NSString stringWithFormat:@"%@",[nameArray objectAtIndex:i]];
        searchMarker.snippet       = @"NYC";
        searchMarker.image         = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]];
        searchMarker.icon          = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        searchMarker.placeId       = [place_idArray objectAtIndex:i];
        
        self.arrayOfSearchMarkers = [NSMutableArray arrayWithObject:searchMarker];
        for (CustomMarker *pin in self.arrayOfSearchMarkers) {
            pin.map = self.mapView;
        }
    }
}

#pragma mark - IBActions
- (IBAction)showWishList:(id)sender {
    [self performSegueWithIdentifier:kListSegue sender:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
