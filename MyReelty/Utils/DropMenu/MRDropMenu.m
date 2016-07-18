//
//  MRDropMenu.m
//  MyReelty
//
//  Created by Dmytro Nosulich on 3/4/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MRDropMenu.h"

#define ROW_HEIGHT      30.f
#define MAX_MENU_HEIGHT 150.f

#define TABLE_HEIGHT (MIN(MAX(ROW_HEIGHT, [_list count] * ROW_HEIGHT), MAX_MENU_HEIGHT))

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MRDropMenu () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;

@property (nonatomic, strong) UIView *hostView;
@property (nonatomic, strong) NSArray *list;

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) UIView *contentDismissView;

@end

@implementation MRDropMenu

+ (instancetype)newMenuWithHostView:(UIView *)hostView list:(NSArray *)list {
    NSArray *viewes = [[NSBundle mainBundle] loadNibNamed:@"MRDropMenu" owner:nil options:nil];
    MRDropMenu *menu = [viewes firstObject];
    menu.hostView = hostView;
    menu.list = list;
    
    return menu;
}

- (void)awakeFromNib {
    _selectedIndex = -1;
}

#pragma mark - User actions

- (IBAction)selectItemDidPressed:(id)sender {
    [self showMenu];
}

- (void)dismissMenu {
    CGRect tableFrame = self.listTableView.frame;
    tableFrame.size.height = 0;
    
    double rads = DEGREES_TO_RADIANS(-0);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    
    [UIView animateWithDuration:0.25 animations:^{
        _listTableView.frame = tableFrame;
        
        _arrowImageView.transform = transform;
    } completion:^(BOOL finished) {
        [_listTableView removeFromSuperview];
        [_contentDismissView removeFromSuperview];
    }];
}

#pragma mark - Public methods

- (void)selectItemAtIndex:(NSInteger)index {
    if(index >= 0 && index < [_list count]) {
        _selectedIndex = index;
        _titleLabel.text = _list[index];
    }
}

#pragma mark - Private methods

- (void)showMenu {
    if(!_hostView) {
        return;
    }
    
    [_hostView addSubview:self.contentDismissView];
    
    CGRect titleAbsoluteFrame = [_titleLabel.superview convertRect:_titleLabel.frame toView:_contentDismissView];
    
    CGRect tableFrame = self.listTableView.frame;
    tableFrame.origin.x = titleAbsoluteFrame.origin.x;
    tableFrame.origin.y = CGRectGetMaxY(titleAbsoluteFrame);
    tableFrame.size.height = 0;
    _listTableView.frame = tableFrame;
    [_contentDismissView addSubview:_listTableView];
    
    tableFrame.size.height = TABLE_HEIGHT;
    
    double rads = DEGREES_TO_RADIANS(180);
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    
    [UIView animateWithDuration:0.25 animations:^{
        _listTableView.frame = tableFrame;
        _arrowImageView.transform = transform;
    }];
}

#pragma mark - Properties

- (UIView *)contentDismissView {
    if(!_contentDismissView) {
        _contentDismissView = [[UIView alloc] initWithFrame:_hostView.bounds];
        _contentDismissView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)];
        tapGesture.delegate = self;
        [_contentDismissView addGestureRecognizer:tapGesture];
    }
    
    return _contentDismissView;
}

- (UITableView *)listTableView {
    if(!_listTableView) {
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, TABLE_HEIGHT)];
        _listTableView.dataSource = self;
        _listTableView.delegate = self;
    }
    return _listTableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = _list[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:11.f];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self selectItemAtIndex:indexPath.row];
    
    [self dismissMenu];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    
    return [view isEqual:_contentDismissView];
}

@end
