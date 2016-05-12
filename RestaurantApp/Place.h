//
//  Place.h
//  RestaurantApp
//
//  Created by Robert Baghai on 5/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject

@property (nonatomic, strong) NSString *formatted_address;
@property (nonatomic, strong) NSString *formatted_phone_number; //different formats for phone number
@property (nonatomic, strong) NSString *international_phone_number;
@property (nonatomic, strong) NSString *name; //place name


//add what ever else we might want for data on a specific place

@end
