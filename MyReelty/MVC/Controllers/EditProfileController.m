//
//  EditProfileController.m
//  MyReelty
//
//  Created by Marian Hunchak on 9/3/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "EditProfileController.h"
#import "DBProfile.h"
#import "Network.h"
#import "Role.h"

static CGFloat pickerCellHeight = 100.f;

@interface EditProfileController() <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    CGFloat currentPickerCellHeight;
}

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneTF;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *rolesPickerView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTV;

@property (strong, nonatomic) NSArray *rolesArray;

@end

@implementation EditProfileController

#pragma mark - Controller Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Edit Profile";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [self addTapGestures];
    
    self.tableView.estimatedRowHeight = 100.f;

    [Network getRolesListWithCompletion:^(NSArray *array, NSError *error) {
        if (array) {
            self.rolesArray = array;
            [self.rolesPickerView reloadAllComponents];
        }
    }];
    
    DBProfile *profile = [DBProfile main];
    
    _profileNameLabel.text = profile.name;
    _phoneTF.text = profile.phone;
    _descriptionTV.text = profile.description_;
    _roleLabel.text = @"Regular";

}

#pragma mark - Actions

- (void)tapOnView {
    
    [self.view endEditing:YES];
}

- (void)handelTapOnProfileImage {
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Take a photo",
                            @"Choose from library",
                            nil];
    [popup showInView:self.view];
}

- (void)saveButtonPressed {
    
}

#pragma mark - Private methods

- (void)addTapGestures {
 
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapOnProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelTapOnProfileImage)];
    tapGesture.cancelsTouchesInView = NO;
    [self.profileImageView addGestureRecognizer:tapOnProfileImage];
    
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 3) {
        
        return  currentPickerCellHeight;
        
    } else if (indexPath.row == 4) {
        
        return UITableViewAutomaticDimension;
    }

    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 2) {
        
        currentPickerCellHeight = currentPickerCellHeight > 0 ? 0 : pickerCellHeight;
        
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [_rolesArray count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ((Role *)_rolesArray[row]).name;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    _roleLabel.text = ((Role *)_rolesArray[row]).name;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 2) return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if (buttonIndex == 1) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
