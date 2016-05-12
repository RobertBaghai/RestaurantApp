//
//  CustomMarker.h
//  MothersDayPlanner
//
//  Created by Robert Baghai on 5/5/16.
//  Copyright © 2016 V-RGB. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface CustomMarker : GMSMarker

@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, strong) NSString *placeId;

@end
