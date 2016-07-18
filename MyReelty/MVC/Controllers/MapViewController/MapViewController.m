//
//  MapViewController.m
//  MyReelty
//
//  Created by Admin on 02.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchViewController.h"
#import "NSCache+Instance.h"
#import "Network+Processing.h"
#import "HCMapAnnotation+Cluster.h"
#import "Review.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PinInfoCollectionView.h"
#import "ReviewViewController.h"
#import "FiltersViewController.h"
#import "FBClusteringManager.h"
#import "Pin.h"
#import "MKMapView+Clustering.h"
#import "PinInfoCollectionCell.h"
#import "MKMapView+ZoomLevel.h"

#define SBSI_GO_TO_FILTER @"showFilters"
#define LABLE_TAG 99

CLGeocoder *geocoder;
CGFloat zoomLevelBefore;
CGFloat zoomLevelAfter;


@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, FBClusteringManagerDelegate, PinInfoCollectionViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewForRevieInfo;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingViewLabel;

@property(nonatomic, retain) CLLocationManager *locationManager;
@property (strong, nonatomic) MKAnnotationView *annotationView;
@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) MKPlacemark *enteredAddressInSearchbar;
@property (nonatomic, strong) PinInfoCollectionView *pinReviewInfoView;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) FBClusteringManager *clusteringManager;
@property (nonatomic, strong) FBAnnotationCluster *selectedCluster;
@property (nonatomic, strong) NSMutableArray *reviews;

@property (nonatomic, assign) BOOL allowLoadMore;
@property (nonatomic, assign) BOOL allowReloadData;
@property (nonatomic, assign) BOOL clusterDidSelected;

@property (nonatomic, strong) UIBarButtonItem *filterButton;
@property (nonatomic, strong) UIBarButtonItem *showGridButton;

@end
int lastAnnotationSelected = 1;
BOOL needToHide = YES;

@implementation MapViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;

    self.navigationItem.titleView = self.searchBar;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.geoCoder = [[CLGeocoder alloc] init];
    
    self.loadingView.layer.cornerRadius = 5.f;
    self.loadingView.layer.masksToBounds = YES;
    
    [self.locationManager startUpdatingLocation];

//    _showGridButton = [[ UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"]
//                                                     style: UIBarButtonItemStylePlain
//                                                    target:self
//                                                    action:@selector(showFeedController:)];
    _showGridButton = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(showFeedController:)];
    
    _showGridButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _showGridButton;
    
//    _filterButton = [[ UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filters"]
//                                                     style: UIBarButtonItemStylePlain
//                                                    target:self
//                                                    action:@selector(showFilters)];
    _filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(showFilters)];
    self.navigationItem.leftBarButtonItem = _filterButton;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardOnTap)];
    [self.view addGestureRecognizer:tapGesture];
    tapGesture.cancelsTouchesInView = NO;

    self.clusteringManager = [[FBClusteringManager alloc] init];
    self.clusteringManager.delegate = self;
    
    _pinReviewInfoView = [PinInfoCollectionView newView];
    _pinReviewInfoView.delegate = self;
    
    if (!self.searchFilter) {
        self.searchFilter = [SearchFilter newFilter];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllData)
                                                 name:LOG_OUT_BUTTON_PRESSED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadAllData)
                                                 name:USER_DID_LOG_IN
                                               object:nil];
    
    zoomLevelBefore = [self.mapView zoomLevel];
    [self.loadingView setHidden:YES];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UITextField *textField = [self.searchBar valueForKey: @"_searchField"];
    [textField setTextColor:[UIColor whiteColor]];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search by ZIP, city or address"
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                                                                   NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.5]
                                                                                   }];
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.5]];
    
    self.searchViewController.searchResultChanged = NO;
    
    if([_clusteringManager.allAnnotations count] == 0 || _searchFilter.isChanged || _searchResultChanged) {
        
        _allowLoadMore = YES;
        if (_searchFilter.isChanged && ![_searchBar.text isEqualToString:@""]) {
            [self didEnterZip:_searchBar.text];
        }
        [self reloadSearchResult:NO whithAdrress:self.searchBar.text];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _searchResultChanged = NO;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOG_OUT_BUTTON_PRESSED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:USER_DID_LOG_IN object:nil];
}

- (SearchViewController *) searchViewController {
    
    if(!_searchViewController) {
        _searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    }
    return _searchViewController;
}

#pragma mark - Actions

- (void) showFeedController: (UIBarButtonItem *) sender {

    if (self.searchViewController.searchResultChanged) {
        [self.searchViewController.tableView setContentOffset:CGPointZero];
    }
    self.searchViewController.searchBar.text = self.searchBar.text;
    self.searchViewController.searchFilter = self.searchFilter;
    [self.navigationController pushViewController:self.searchViewController animated:NO];
}

- (void) showFilters {
    [self.searchBar resignFirstResponder];
    [self performSegueWithIdentifier:SBSI_GO_TO_FILTER sender:self];
}

#pragma mark - Private methods

- (void)reloadSearchResult:(BOOL)loadMore whithAdrress:(NSString *)pAddress {
    
    self.loadingViewLabel.text = @"Loading...";
    [self.loadingView setHidden:NO];
    
    if (!self.searchViewController.searchResultChanged) {
        self.searchViewController.searchResultChanged = _searchFilter.isChanged;
    }
    _searchFilter.isChanged = NO;

    if ([pAddress isEqualToString:@""]) {
        pAddress = self.userLocationString;
    }

    pAddress = [pAddress encodeUrlString];
    
    __weak typeof(self)weakSelf = self;
    
   [Network getPinsListWhithAddress:pAddress andFilter:weakSelf.searchFilter WithCompletion:^(NSArray *array, NSError *error) {

       if (!error) {
           if ([array count] == 0) {
               weakSelf.loadingViewLabel.text = @"Nothing was found";
               [weakSelf.loadingView setHidden:NO];
           } else {
               [weakSelf.loadingView setHidden:YES];
           }
           NSMutableArray *annotations = [NSMutableArray array];
           for (Pin *pin in array) {
               HCMapAnnotation *ann = [HCMapAnnotation new];
               ann.reviewID = pin.id_;
               ann.coordinate = pin.location;
               [annotations addObject:ann];
           }
           [weakSelf.clusteringManager removeAnnotations:self.clusteringManager.allAnnotations];
           [weakSelf.clusteringManager addAnnotations:annotations];
           [weakSelf mapView:weakSelf.mapView regionDidChangeAnimated:YES];
           [weakSelf.mapView showAnnotations:weakSelf.clusteringManager.allAnnotations animated:NO];
       }
   }];
}

- (void) hideKeyboardOnTap {
    
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}

- (void)didEnterZip:(NSString*)zip {
    if (self.geoCoder.geocoding) [self.geoCoder cancelGeocode];
    [self.geoCoder geocodeAddressString:(NSString *)zip
                     completionHandler:^(NSArray *placemarks, NSError *error) {
             if ([placemarks count] > 0 && !error) {
                 for (CLPlacemark* placemark in placemarks) {
                     if ([placemark.ISOcountryCode isEqualToString:@"US"] || [placemark.ISOcountryCode isEqualToString:@"UA"]) {
                         self.enteredAddressInSearchbar = [[MKPlacemark alloc] initWithPlacemark:placemark];
                         break;
                     } else {
                         self.enteredAddressInSearchbar = [[MKPlacemark alloc] initWithPlacemark:[placemarks firstObject]];
                     }
                 }
                 
                 if (!self.enteredAddressInSearchbar.locality) {
                     [self showEnteredInSearchBarLocationWhithDelta:3000000];
                 } else {
                     [self showEnteredInSearchBarLocationWhithDelta:100000];
                 }
                 
             } 
    }];
}

- (void) showEnteredInSearchBarLocationWhithDelta:(double) delta {
    
    MKMapRect zoomRect = MKMapRectNull;
    
    CLLocationCoordinate2D location = self.enteredAddressInSearchbar.coordinate;
    
    MKMapPoint center =  MKMapPointForCoordinate(location);
    
    MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
    
    zoomRect = MKMapRectUnion(zoomRect, rect);
    zoomRect = [self.mapView mapRectThatFits:zoomRect];

    [self.mapView setVisibleMapRect:zoomRect
                    edgePadding:UIEdgeInsetsMake(50, 50, 50, 50)
                       animated:NO];
    
    [self.mapView removeAnnotation:self.enteredAddressInSearchbar];
    
}

- (BOOL) isVisibleCluster:(FBAnnotationCluster *) pCluster {
    
   return MKMapRectContainsPoint(_mapView.visibleMapRect, MKMapPointForCoordinate(pCluster.coordinate));
}

- (void)showAlertWithMessage:(NSString *)message handler:(void (^)(UIAlertAction *action))handler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
        
    if (status == kCLAuthorizationStatusNotDetermined) {
        
        [self.locationManager requestWhenInUseAuthorization];
        return;
        
    }
    [self.locationManager startUpdatingLocation];
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        __weak typeof(self) wealSelf = self;
        
        [self.geoCoder cancelGeocode];
        [self.geoCoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if (!error && [placemarks count]) {
                CLPlacemark *placemark = [placemarks objectAtIndex:0];
                wealSelf.enteredAddressInSearchbar = [[MKPlacemark alloc] initWithPlacemark:placemark];
                [wealSelf showEnteredInSearchBarLocationWhithDelta:100000];
                _allowReloadData = YES;
                wealSelf.userLocationString = placemark.locality;
                [wealSelf reloadSearchResult:NO whithAdrress:placemark.locality];
            }
             wealSelf.showGridButton.enabled = YES;
        }];
    } else {
        
        self.userLocationString = @"Los Angeles";
        [self didEnterZip: self.userLocationString];
        self.allowLoadMore = YES;
        [self reloadSearchResult:NO whithAdrress: self.userLocationString];
        self.showGridButton.enabled = YES;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    if (_clusterDidSelected && zoomLevelBefore == [mapView zoomLevel] && [self isVisibleCluster:_selectedCluster]) {
        return;
    }
    
        [[NSOperationQueue new] addOperationWithBlock:^{
            double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
            
            NSArray *annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
            [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
        }];

    zoomLevelBefore = [_mapView zoomLevel];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    NSArray *lAnnotationsArray;
    
    if ([view.annotation isKindOfClass:[FBAnnotationCluster class]]) {
        FBAnnotationCluster *cluster = (FBAnnotationCluster *)view.annotation;
        lAnnotationsArray = cluster.annotations;
        _selectedCluster = cluster;
        _clusterDidSelected = YES;
        [UIView animateWithDuration:0.25 animations:^{
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15, 1.15);
        }];
    } else {
        HCMapAnnotation *ann = (HCMapAnnotation *)view.annotation;
        lAnnotationsArray = @[ann];
        _clusterDidSelected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            view.image = [UIImage imageNamed:@"pinImage(Active)"];
        }];
    }
    _pinReviewInfoView = [PinInfoCollectionView newView];
    _pinReviewInfoView.delegate = self;
    _pinReviewInfoView.pinsArray = lAnnotationsArray;
    [self.viewForRevieInfo addSubview:_pinReviewInfoView];
    _pinReviewInfoView.frame = self.viewForRevieInfo.bounds;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        [self.viewForRevieInfo setHidden:NO];
    } completion:nil];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
        if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
            return;
        }
        if ([view.annotation isKindOfClass:[HCMapAnnotation class]]) {
            
            [UIView animateWithDuration:0.25 animations:^{
                view.image = [UIImage imageNamed:@"pinImage"];
                [self.viewForRevieInfo setHidden:YES];
            }];
        } else if ([view.annotation isKindOfClass:[FBAnnotationCluster class]]) {
            _clusterDidSelected = NO;
            
            [UIView animateWithDuration:0.25 animations:^{
                view.transform = CGAffineTransformIdentity;
                [self.viewForRevieInfo setHidden:YES];
            }];
        }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
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
    
    if ([annotation isKindOfClass:[FBAnnotationCluster class]]) {
        UILabel *label = nil;
        BOOL createLabel = NO;
        
        if(!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            createLabel = YES;
        } else {
            label = getLable(annotationView);
            label.hidden = NO;
            createLabel = label == nil;
        }
        
        if(createLabel) {
        
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25.f, 25.f)];
            label.font = [UIFont systemFontOfSize:15];
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.3;
            label.layer.cornerRadius = label.frame.size.width / 2.0;
            label.layer.borderWidth = 2.f;
            label.layer.borderColor = [UIColor whiteColor].CGColor;
            label.layer.masksToBounds = YES;
            
            label.backgroundColor = navigationBarColor;
            
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = LABLE_TAG;
            [annotationView addSubview:label];
        }
        FBAnnotationCluster *cluster = (FBAnnotationCluster *)annotation;
        label.text = [NSString stringWithFormat:@"%lu", [cluster.annotations count]];
        annotationView.frame = label.frame;
        annotationView.image = nil;
        
    } else {
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            UILabel *label = getLable(annotationView);
            label.hidden = YES;
        }
        
        annotationView.image = [UIImage imageNamed:@"pinImage"];
    }
    
    return annotationView;
}

#pragma mark - UISearchResultsUpdating


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    _clusterDidSelected = NO;
    self.searchViewController.searchResultChanged = YES;
//    [self didEnterZip:searchBar.text];
    [self reloadSearchResult:NO whithAdrress:searchBar.text];
    [self mapView:self.mapView regionDidChangeAnimated:NO];

    [searchBar resignFirstResponder];
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SBSI_GO_TO_FILTER]) {
        FiltersViewController *filterVC = segue.destinationViewController;
        filterVC.filter = _searchFilter;
    }
}

#pragma mark - Notifications 

- (void)reloadAllData {
    
    self.searchBar.text = @"";
    [self.searchFilter resetFilters];
    [self didEnterZip:_userLocationString];
    [self.clusteringManager removeAnnotations:self.clusteringManager.allAnnotations];
}

#pragma mark - PinInfoCollectionViewDelegate  

- (void)pinInfoCollectionViewDidSelectCell:(Review *)pReview {
    
    ReviewViewController *reviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewController"];
    reviewVC.reiew = pReview;
    
    [self.navigationController pushViewController:reviewVC animated:YES];
}

@end
