//
//  AnnotationView.h
//  RestaurantApp
//
//  Created by Robert Baghai on 5/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnotationView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *subTitleLabel;

@end
