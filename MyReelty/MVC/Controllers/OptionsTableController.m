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


@interface OptionsTableController ()

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
        case 0: [Network updateUserProfile:nil];
            break;
        case 1: [self showAboutViewControllerForRow:indexPath.row];
            break;
        case 2: [self logOut];
            break;
        default:
            break;
    }
}
#pragma mark - Private methods

- (void) logOut {
    [self showAlertWitHandler:^(UIAlertAction *action) {
        [DBProfile main].autorized = [NSNumber numberWithBool:NO];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
