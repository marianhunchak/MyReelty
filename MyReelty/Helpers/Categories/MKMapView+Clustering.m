//
//  MKMapView+Clustering.m
//  MyReelty
//
//  Created by Marian Hunchak on 4/7/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MKMapView+Clustering.h"
#import <objc/runtime.h>
#import "Pin.h"
#import "HCMapAnnotation+Cluster.h"

static void * CellSizePropertyKey;
static void * UseClusterPropertyKey;

@implementation MKMapView (Clustering)

#pragma mark - Properties

- (CGSize )cellSize {
    return [objc_getAssociatedObject(self, &CellSizePropertyKey) CGSizeValue];
}

- (void)setCellSize:(CGSize)cellSize {
    objc_setAssociatedObject(self, &CellSizePropertyKey, [NSValue valueWithCGSize:cellSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL )useCluster {
    return [objc_getAssociatedObject(self, &UseClusterPropertyKey) boolValue];
}

- (void)setUseCluster:(BOOL)useCluster {
    objc_setAssociatedObject(self, &UseClusterPropertyKey, [NSNumber numberWithBool:useCluster], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public methods

- (void)reloadPins:(NSArray *) pins {
    if (self.useCluster && [pins count] > 1) {
        if (CGSizeEqualToSize(self.cellSize, CGSizeZero)) {
            self.cellSize = CGSizeMake(35.f, 35.f);
        }
        NSArray *testPins = [self getTestPins:50000];
        
        NSLog(@"----------------------------------------------");
        NSLog(@"--------start MAP UPDATE: - %@", [NSDate date]);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self addPinsWithCluster:testPins];
        });
        
    } else {
        for (Pin *pin in pins) {
            HCMapAnnotation *ann = [[HCMapAnnotation alloc] init];
            ann.coordinate = pin.location;
            ann.reviewID = pin.id_;
            [self addAnnotation:ann];
        }
    }
}

#pragma mark - Private methods

-(void)addPinsWithCluster:(NSArray *) pins {
    
//    NSLog(@"zoom level: %f", self.region.span.longitudeDelta);
    
    MKCoordinateSpan lSpan = self.region.span;
    
    MKMapRect lRect = self.visibleMapRect;
    
    CGSize sheetSize = CGSizeMake(round(self.frame.size.width / self.cellSize.width) - 1,
                                  round(self.frame.size.height / self.cellSize.height) - 1);
    double lonDelta = lSpan.longitudeDelta / sheetSize.width;
    double latDelta = lSpan.latitudeDelta / sheetSize.height;
    
    NSMutableArray *sheetArray = [NSMutableArray new];
    CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(lRect.origin);

    for (int row = 0 ; row < sheetSize.height; row++) {
        
        NSMutableArray *rowArray = [NSMutableArray new];
        
        for (int col = 0 ; col < sheetSize.width; col++) {
            HCMapAnnotation *ann = [HCMapAnnotation new];
            ann.isCluster = YES;
            CLLocationCoordinate2D cellCenter = CLLocationCoordinate2DMake((coordinate.latitude - latDelta  * (1 + row)) + latDelta / 2.0,
                                                                           (coordinate.longitude + lonDelta * (1 + col) - lonDelta / 2.0));
            ann.coordinate = cellCenter;
            [rowArray addObject:ann];
        }
        
        [sheetArray addObject:rowArray];
    }
    
    static NSUInteger visiblePins = 0;
    NSUInteger newVisiblePins = 0;
    
    static float zoomDelta = 0;
    float newZoomDelta = self.region.span.longitudeDelta;

    for (Pin *pin in pins) {
        if (MKMapRectContainsPoint(lRect, MKMapPointForCoordinate(pin.location))) {
            HCMapAnnotation *ann = [HCMapAnnotation new];
            ann.coordinate = pin.location;
            ann.reviewID = pin.id_;
            
            double lonPinDelta = fabs(fabs(coordinate.longitude) - fabs(ann.coordinate.longitude));
            double latPinDelta = fabs(fabs(coordinate.latitude) - fabs(ann.coordinate.latitude));
            
            NSInteger row = ceil(latPinDelta / latDelta) - 1;
            NSInteger col = ceil(lonPinDelta / lonDelta) - 1;
            
            HCMapAnnotation *clusterAnnotation = sheetArray[row][col];
            [clusterAnnotation addClusterAnnotations:@[ann]];
            
            newVisiblePins++;
        }
    }
    
    float zoomMinDelta = 0.02;
    if(newVisiblePins <= visiblePins && fabsf(fabsf(newZoomDelta) - fabsf(zoomDelta)) <= zoomMinDelta) {
        return;
    }
    visiblePins = newVisiblePins;
    zoomDelta = newZoomDelta;
    
    NSLog(@"--------finish calculate MAP UPDATE: - %@", [NSDate date]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self removeAnnotations:self.annotations];
        [self addPinsFromSheet:sheetArray];
    });
}

- (void) addPinsFromSheet:(NSArray *)sheetArray {
    for (int row = 0 ; row < [sheetArray count]; row++) {
        NSMutableArray *rowArray = sheetArray[row];
        for (int col = 0 ; col < [rowArray count]; col++) {
            HCMapAnnotation *ann = rowArray[col];
            
            if ([ann.annotations count] == 1) {
                [self addAnnotation:[ann.annotations firstObject]];
            } else if ([ann.annotations count] > 1) {
                [self addAnnotation:ann];
            }
        }
    }
    NSLog(@"--------finish MAP UPDATE: - -----%@", [NSDate date]);
}

#pragma mark - Test methods

- (NSArray *)getTestPins:(NSInteger) count {
    static NSArray *testValues = nil;
    
    if(!testValues) {
        NSMutableArray *pins = [NSMutableArray new];
        
        Pin *mainPin = [Pin new];
        mainPin.location = CLLocationCoordinate2DMake(34.111956900000003, -118.255139);
        for(int i = 0; i < count; i++) {
            float lat = arc4random()%11 * (0.001);
            float lon = arc4random()%11 * (0.001);
            
            int latSign = arc4random()%2;
            int lonSign = arc4random()%2;
            
            Pin *newPin = [Pin new];
            newPin.id_ = [NSString stringWithFormat:@"%i", i];
            newPin.location = CLLocationCoordinate2DMake(mainPin.location.latitude + (latSign > 0 ? 1 : -1) * lat,
                                                         mainPin.location.longitude + (lonSign > 0 ? 1 : -1) * lon);
            [pins addObject:newPin];
            mainPin = newPin;
        }
        testValues = pins;
    }
    return testValues;
}


@end
