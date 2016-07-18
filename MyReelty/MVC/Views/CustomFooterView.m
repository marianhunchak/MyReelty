//
//  CustomFooterView.m
//  MyReelty
//
//  Created by Marian Hunchak on 04/03/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CustomFooterView.h"
#import <MapKit/MapKit.h>
#import "HCMapAnnotation.h"
#import "NSString+DivideNumber.h"

@interface CustomFooterView() <MKMapViewDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *availabilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel2;
@property (weak, nonatomic) IBOutlet UILabel *prpertyTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bedsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bathsLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation CustomFooterView

+ (instancetype)newView {
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"CustomFooterView" owner:nil options:nil];
    
    CustomFooterView *newFooterView = [viewes firstObject];
    return newFooterView;
}

- (void)setReview:(Review *)review {
    _review = review;
    
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@, %@, %@", review.address, review.city, review.state, review.zipcode];
    self.descriptionLabel.text = review.description_;
    if (review.availability == YES) {
        self.availabilityLabel.layer.cornerRadius = 8.f;
        self.availabilityLabel.layer.masksToBounds = YES;
        self.priceLabel.text = [NSString stringWithFormat:@" $ %@",[[ NSString stringWithFormat:@"%1.f" , review.price] divideNumber]];
    } else {
    for (NSLayoutConstraint *constarint in self.availabilityLabel.constraints) {
        if ([constarint.identifier isEqualToString:@"avalabilityLabelWidth"]) {
            constarint.constant = 0;
            self.priceLabel.text = [NSString stringWithFormat:@"$ %@",[[ NSString stringWithFormat:@"%1.f" , review.price] divideNumber]];
        }
    }
    }
    self.statusLabel.text = review.availability ? @"For sale" : @"Not for sale";
    self.priceLabel2.text = [NSString stringWithFormat:@"$ %@",[[ NSString stringWithFormat:@"%1.f" , review.price] divideNumber]];
    self.prpertyTypeLabel.text = review.property_type;
    self.bedsLabel.text = [NSString stringWithFormat:@"%li",review.beds];
    self.bathsLabel.text = [NSString stringWithFormat:@"%li",review.baths];
    self.sizeLabel.text = [[[NSString stringWithFormat:@"%1.f", review.square] divideNumber] stringByAppendingString:@" sqft"];
    self.mapView.delegate = self;
   
    CLLocationCoordinate2D coord = review.location;
    HCMapAnnotation *ann = [[HCMapAnnotation alloc] init];
    ann.coordinate = coord;
    [self.mapView addAnnotation:ann];
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *identifier = @"Annotation";
    MKAnnotationView *annotationView =  (MKAnnotationView*) [ mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        MKAnnotationView *annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        annoView.image = [UIImage imageNamed:@"pinImage(Active)"];
        return annoView;
    }
    return annotationView;
    
}

#pragma mark - Private methods

+ (CGFloat)heightForDescription:(NSString *)description inTable:(UITableView *)tableView {
    CGSize commentLabelSize = CGSizeMake(tableView.frame.size.width - 26.f, 99999);
    CGSize size = [description boundingRectWithSize:commentLabelSize
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]}
                                        context:nil].size;
    return size.height;
}

- (void) showUnitedPinsRect {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        CLLocationCoordinate2D location = annotation.coordinate;
        
        MKMapPoint center =  MKMapPointForCoordinate(location);
        
        static double delta = 10000;
        
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    
    zoomRect = [ self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                           animated:NO];
    
}

@end
