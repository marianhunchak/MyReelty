//
//  OptionsTableController.m
//  MyReelty
//
//  Created by Marian Hunchak on 5/5/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "OptionsTableController.h"
#import "DBProfile.h"
#import "PrivacyPolicyController.h"
#import "Network.h"
#import <MessageUI/MessageUI.h>
#import "EditProfileController.h"


@interface OptionsTableController () <MFMailComposeViewControllerDelegate>

@end

@implementation OptionsTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Options";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0: [self showEditProfileController];
            break;
        case 1:
            
            if (indexPath.row == 2) {
                [self sendMail];
                return;
            }
            
            [self showAboutViewControllerForRow:indexPath.row];
            break;
        case 2: [self logOut];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 0.f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.f;
    }
    
    return [super tableView:tableView heightForHeaderInSection:section];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.f;
    }
    
    return [super tableView:tableView heightForFooterInSection:section];
}

#pragma mark - Private methods

- (void)showEditProfileController {
    
    EditProfileController *controller = VIEW_CONTROLLER(@"EditProfileController");
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void) logOut {
    [self showAlertWitHandler:^(UIAlertAction *action) {
        [[DBProfile main] MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACCESS_TOKEN_DICT_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOG_OUT_BUTTON_PRESSED object:nil];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }];
}

- (void) showAboutViewControllerForRow:(NSUInteger) row {
    
    PrivacyPolicyController *vc = VIEW_CONTROLLER(@"PrivacyPolicyController");
    vc.infoType = row;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)showAlertWitHandler:(void (^)(UIAlertAction *action))handler {
    
    NSString *title = @"Are you sure you want to log out?";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(action);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"MyReelty support"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[@"info@myreelty.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
                DLog(@"This device cannot send email");
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
                        DLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
                        DLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
                        DLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
                        DLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
                        DLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
