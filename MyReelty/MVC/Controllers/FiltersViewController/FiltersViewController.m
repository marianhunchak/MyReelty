//
//  FiltersViewController.m
//  MyReelty
//
//  Created by Admin on 2/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "FiltersViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "SearchFilter.h"
#import "MRDropMenu.h"
#import "MRDoubleSlider.h"
#import "MRSetSelection.h"

@interface FiltersViewController () <MRDoubleSliderDelegate> {
    BOOL willDisappear;
}

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIButton *onMarketButton;
@property (nonatomic, weak) IBOutlet UIButton *offMarketButton;

@property (nonatomic, weak) IBOutlet UIView *dropMenuContentView;
@property (nonatomic, weak) IBOutlet UIView *priceSliderContentView;
@property (nonatomic, weak) IBOutlet UIView *sizeSliderContentView;
@property (nonatomic, weak) IBOutlet UIView *bedsSetContentView;
@property (nonatomic, weak) IBOutlet UIView *bathsSetContentView;

@property (nonatomic, weak) IBOutlet UIButton *applyFiltersButton;

@property (nonatomic, strong) MRDropMenu *dropMenu;
@property (nonatomic, strong) MRDoubleSlider *priceSlider;
@property (nonatomic, strong) MRDoubleSlider *sizeSlider;
@property (nonatomic, strong) MRSetSelection *bedsSetSelection;
@property (nonatomic, strong) MRSetSelection *bathsSetSelection;

@end

@implementation FiltersViewController

#pragma mark Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(resetBtnPressed:)];
    self.navigationItem.rightBarButtonItem = resetButton;
    _applyFiltersButton.layer.cornerRadius = _applyFiltersButton.frame.size.height / 2.f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(willDisappear) {
        willDisappear = NO;
        
        return;
    }
    
//    self.navigationController.hidesBarsOnSwipe = NO;
    
    [self.view updateConstraints];
    
    _dropMenu = [MRDropMenu newMenuWithHostView:self.view list:@[@"House", @"Condo", @"Townhouse", @"Other", @"Any"]];
    _dropMenu.frame = _dropMenuContentView.bounds;
    [_dropMenuContentView addSubview:_dropMenu];
    if(_filter) {
        [_dropMenu selectItemAtIndex:_filter.typeOfProperty];
    }
    
    if(_filter) {
        _onMarketButton.selected = _filter.onTheMarket;
        _offMarketButton.selected = _filter.offTheMarket;
    }
    
    NSRange selectedRange = NSMakeRange(50000, 10000000);
    if(_filter) {
        selectedRange = NSMakeRange(_filter.priceMin, _filter.priceMax);
    }
    _priceSlider = [MRDoubleSlider newSliderWithRange:NSMakeRange(50000, 10000000)];
    _priceSlider.frame = _priceSliderContentView.bounds;
    [_priceSliderContentView addSubview:_priceSlider];
    _priceSlider.displayLabelStr = @"$";
    _priceSlider.labelDisplayFormat = LabelDisplayFront;
    _priceSlider.selectedRange = selectedRange;
    _priceSlider.useNumberDivider = YES;
    _priceSlider.showMaxValueIndicator = YES;
    _priceSlider.delegate = self;
    
    _bedsSetSelection = [MRSetSelection newSetSelectionWithItems:@[@"Any", @"1", @"2", @"3", @"4", @"5+"]];
    _bedsSetSelection.frame = _bedsSetContentView.bounds;
    NSInteger selectedBeds = 0;
    if(_filter) {
        selectedBeds = _filter.beds;
    }
    [_bedsSetSelection setSelectedItem:selectedBeds];
    [_bedsSetContentView addSubview:_bedsSetSelection];
    
    _bathsSetSelection = [MRSetSelection newSetSelectionWithItems:@[@"Any", @"1", @"2", @"3", @"4", @"5+"]];
    _bathsSetSelection.frame = _bathsSetContentView.bounds;
    NSInteger selectedBaths = 0;
    if(_filter) {
        selectedBaths = _filter.baths;
    }
    [_bathsSetSelection setSelectedItem:selectedBaths];
    [_bathsSetContentView addSubview:_bathsSetSelection];
    
    selectedRange = NSMakeRange(500, 3000);
    if(_filter) {
        selectedRange = NSMakeRange(_filter.sizeMin, _filter.sizeMax);
    }
    _sizeSlider = [MRDoubleSlider newSliderWithRange:NSMakeRange(500, 3000)];
    _sizeSlider.frame = _sizeSliderContentView.bounds;
    [_sizeSliderContentView addSubview:_sizeSlider];
    _sizeSlider.selectedRange = selectedRange;
    _sizeSlider.displayLabelStr = @"sq ft";
    _sizeSlider.labelDisplayFormat = LabelDisplayBack;
    _sizeSlider.showMaxValueIndicator = YES;
    _sizeSlider.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_priceSlider updateComponents];
        [_sizeSlider updateComponents];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height = 600;
    _scrollView.contentSize = contentSize;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    self.navigationController.hidesBarsOnSwipe = YES;
    
    willDisappear = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User actions

- (IBAction)onMarketPressed:(id)sender {
    _onMarketButton.selected = YES;
    _offMarketButton.selected = NO;
}

- (IBAction)offMarketPressed:(id)sender {
    _onMarketButton.selected = NO;
    _offMarketButton.selected = YES;
}

- (IBAction)applyFiltersPressed:(id)sender {
    if(!_filter) {
        _filter = [SearchFilter newFilter];
    }
    _filter.isChanged = YES;
    
    _filter.typeOfProperty = _dropMenu.selectedIndex;
    _filter.onTheMarket = _onMarketButton.selected;
    _filter.offTheMarket = _offMarketButton.selected;
    _filter.priceMin = _priceSlider.validRange.location;
    _filter.priceMax = _priceSlider.validRange.length;
    _filter.beds = _bedsSetSelection.selectedItem;
    _filter.baths = _bathsSetSelection.selectedItem;
    _filter.sizeMin = _sizeSlider.validRange.location;
    _filter.sizeMax = _sizeSlider.validRange.length;
    
    if(self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private methods

#pragma mark - Actions

- (void) resetBtnPressed:(UIBarButtonItem *) sender {
    
    [_dropMenu selectItemAtIndex:4];
    
    _onMarketButton.selected = false;
    _offMarketButton.selected = false;
    
    NSRange selectedRange = NSMakeRange(50000, 10000000);
    _priceSlider.selectedRange = selectedRange;
    
    NSInteger selectedBeds = 0;
    [_bedsSetSelection setSelectedItem:selectedBeds];
    
    NSInteger selectedBaths = 0;
    [_bathsSetSelection setSelectedItem:selectedBaths];
    
    selectedRange = NSMakeRange(500, 3000);
    _sizeSlider.selectedRange = selectedRange;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_priceSlider updateComponents];
        [_sizeSlider updateComponents];
    });

}

#pragma mark - MRDoubleSliderDelegate

- (void)doubleSliderDidStartDraging:(MRDoubleSlider *)slider {
    self.scrollView.scrollEnabled = NO;
}

- (void)doubleSliderDidFinishDraging:(MRDoubleSlider *)slider {
    self.scrollView.scrollEnabled = YES;
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
