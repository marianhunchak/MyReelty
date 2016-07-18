//
//  HCMapAnnotation+Cluster.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "HCMapAnnotation+Cluster.h"
#import <objc/runtime.h>

#define LABLE_TAG 99

static char IsClusterPropertyKey;
static NSString const * const AnnotationsPropertyKey = @"kAnnotationsPropertyKey";;

@implementation HCMapAnnotation (Cluster)

#pragma mark - Properties

- (BOOL)isCluster {
    return [objc_getAssociatedObject(self, &IsClusterPropertyKey) boolValue];
}

- (void)setIsCluster:(BOOL)isCluster {
    objc_setAssociatedObject(self, &IsClusterPropertyKey, [NSNumber numberWithBool:isCluster], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)annotations {
    return objc_getAssociatedObject(self, &AnnotationsPropertyKey);
}

- (void)setannotations:(NSArray *)annotations {
    objc_setAssociatedObject(self, &AnnotationsPropertyKey, annotations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public methods

-(MKAnnotationView *) annotationViewForAnnotationInMap:(MKMapView *) mapView {
    
    static NSString *identifier = @"Annotation";
    MKAnnotationView *annotationView =  (MKAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    UILabel * (^getLable)(MKAnnotationView *) = ^(MKAnnotationView *annotationView) {
        UILabel *label = nil;
        for(UIView *subView in annotationView.subviews) {
            if(subView.tag == LABLE_TAG) {
                label = (UILabel *)subView;
            }
        }
        return label;
    };
    
    if (self.isCluster) {
        UILabel *label = nil;
        BOOL createLabel = NO;
        
        if(!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:identifier];
            
            createLabel = YES;
        } else {
            label = getLable(annotationView);
            label.hidden = NO;
            createLabel = label == nil;
        }
        
        if(createLabel) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25.f, 25.f)];
            label.font = [UIFont systemFontOfSize:11];
            label.layer.cornerRadius = label.frame.size.width / 2.0;
            label.layer.borderWidth = 3.f;
            label.layer.borderColor = [UIColor whiteColor].CGColor;
            label.layer.masksToBounds = YES;
            
            label.backgroundColor = navigationBarColor;
            
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = LABLE_TAG;
            [annotationView addSubview:label];
        }
        label.text = [NSString stringWithFormat:@"%lu", self.annotations.count];
        annotationView.frame = label.frame;
        annotationView.image = nil;
        
    } else {
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:identifier];
        } else {
            UILabel *label = getLable(annotationView);
            label.hidden = YES;
        }
        
        annotationView.image = [UIImage imageNamed:@"pinImage"];
    }
    
    return annotationView;
}

//-(void) addClusterAnnotations:(NSArray *) array {
//    if ([array count] == 0) {
//        return;
//    }
//    NSMutableArray *lArray = [NSMutableArray arrayWithArray:self.annotations];
//    if (!lArray) {
//        lArray = [NSMutableArray new];
//    }
//    [lArray addObjectsFromArray:array];
//    [self setannotations:lArray];
//    
////    if([lArray count] > 1) {
////        [self calculateAverageLocation];
////    }
//}
//
//- (void) calculateAverageLocation {
//    double count = 0;
//    double lat = 0;
//    double lon = 0;
//    for(HCMapAnnotation *ann in self.annotations) {
//        count++;
//        
//        lat += ann.coordinate.latitude;
//        lon += ann.coordinate.longitude;
//    }
//    
//    self.coordinate = CLLocationCoordinate2DMake(lat / count, lon / count);
//}

@end
