//
//  ProfileCellTableViewCell.m
//  MyReelty
//
//  Created by Admin on 2/25/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfileCellTableViewCell.h"
#import "DBProfile.h"
#import "Profile.h"
#import "Network+Processing.h"
#import "NSString+ValidateValue.h"
#import "NSDate+TimeAgo.h"
#import "NSDate+String.h"

#define BASE_CELL_HEIGHT 100.f

@interface ProfileCellTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarUser;
@property (weak, nonatomic) IBOutlet UILabel *nameUser;
@property (weak, nonatomic) IBOutlet UILabel *timeRegistration;
@property (weak, nonatomic) IBOutlet UILabel *emailUser;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberUser;
@property (weak, nonatomic) IBOutlet UILabel *infoUser;

@property (strong, nonatomic) NSString *filePath;

@end


@implementation ProfileCellTableViewCell

- (void) setProfile:(DBProfile *)profile {
    _profile = profile;
    self.avatarUser.image = nil;
    self.nameUser.text = profile.name;
    self.timeRegistration.text = [profile.created_at substringToIndex:10];
    
    [self configureTimeRegistrationLabelWithProfile:profile];
    
    self.emailUser.text = [NSString validateValue:profile.email];
    self.infoUser.text = [NSString validateValue:profile.description_];
    self.phoneNumberUser.text = [NSString validateValue:profile.phone];
    if (![NSString validateValue:profile.avatarUrl]) {
        self.avatarUser.image = [UIImage imageNamed:@"avatar(Empty)"];
    } else {
        
        if ([profile isKindOfClass:[Profile class]]) {
            NSString *url1 = profile.avatarUrl;
            [self.avatarUser setImageWithURL:[NSURL URLWithString:url1] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        } else
            _avatarUser.image = [self getImageWithFilePath] ? [self getImageWithFilePath] : [UIImage imageNamed:@"avatar(Empty)"];
    }
}

- (void)awakeFromNib {
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateProfile)
//                                                 name:LOG_OUT_BUTTON_PRESSED
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfileAvatar:)
                                                 name:PROFILE_AVATAR_DID_LOADED
                                               object:nil];
    self.avatarUser.image = nil;
    self.nameUser.text = @"";
    self.timeRegistration.text = @"";
    self.emailUser.text = @"";
    self.infoUser.text = @"";
    self.phoneNumberUser.text = @"";
    self.avatarUser.layer.cornerRadius = 5.f;
    self.avatarUser.layer.masksToBounds = YES;
    self.avatarUser.clipsToBounds = YES;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods

- (void)configureTimeRegistrationLabelWithProfile:(DBProfile *) profile {
    
    NSDate *date = [NSDate getDateFromString:profile.created_at];
    
    NSString *roleName = profile.roleName ? profile.roleName : @"Regular User";
    NSString *timeAgo = [date timeAgo] ? [date timeAgo] : @"";
    
    NSString *fullString = [[timeAgo stringByAppendingString:@"   "] stringByAppendingString:roleName];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:fullString];
    NSRange boldedRange = NSMakeRange(timeAgo.length + 3, roleName.length);
    UIFont *fontText = [UIFont boldSystemFontOfSize:12];
    NSDictionary *dictBoldText = [NSDictionary dictionaryWithObjectsAndKeys:fontText, NSFontAttributeName, nil];
    [attrString setAttributes:dictBoldText range:boldedRange];
    
    self.timeRegistration.attributedText = attrString;
}

+ (CGFloat)heightForInfoUser:(NSString *)infoUserLabel inTable:(UITableView *)tableView {
    CGSize infoUserLabelSize = CGSizeMake(tableView.frame.size.width - 30.f, 99999);
    CGSize size = [infoUserLabel boundingRectWithSize:infoUserLabelSize
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]}
                                        context:nil].size;
    return BASE_CELL_HEIGHT + size.height;
}


- (NSString *)documentsPathForFileName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
}


- (UIImage *) getImageWithFilePath {

    NSData *pngData = [NSData dataWithContentsOfFile:[self documentsPathForFileName:@"image.png"]];
    UIImage *image = [UIImage imageWithData:pngData];

    return image;
}

#pragma mark - Notifications 

- (void) updateProfileAvatar:(NSNotification *) pNotification {
    
    [self setProfile:[DBProfile main]];
}

@end
