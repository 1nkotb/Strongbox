//
//  SelectStorageProviderController.m
//  StrongBox
//
//  Created by Mark on 08/09/2017.
//  Copyright © 2017 Mark McGuill. All rights reserved.
//

#import "SelectStorageProviderController.h"
#import "SafeStorageProvider.h"
#import "LocalDeviceStorageProvider.h"
#import "GoogleDriveStorageProvider.h"
#import "DropboxV2StorageProvider.h"
#import "CustomStorageProviderTableViewCell.h"
#import "AddSafeAlertController.h"
#import "DatabaseModel.h"
#import "Alerts.h"
#import "StorageBrowserTableViewController.h"
#import "AppleICloudProvider.h"
#import "Settings.h"
#import "SafesList.h"
#import "OneDriveStorageProvider.h"
#import "AddNewSafeHelper.h"
#import "SFTPStorageProvider.h"
#import "WebDAVStorageProvider.h"
#import "InitialViewController.h"

@interface SelectStorageProviderController ()

@property (nonatomic, copy, nonnull) NSArray<id<SafeStorageProvider>> *providers;

@end

@implementation SelectStorageProviderController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.existing) {
        [self.navigationItem setPrompt:@"Select where your existing safe is stored"];
    }
    else {
        [self.navigationItem setPrompt:@"Select where you would like to store your new safe"];
    }

    self.navigationController.toolbar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SFTPStorageProvider* sftpProviderWithFastListing = [[SFTPStorageProvider alloc] init];
    sftpProviderWithFastListing.maintainSessionForListing = YES;

    WebDAVStorageProvider* webDavProvider = [[WebDAVStorageProvider alloc] init];
    webDavProvider.maintainSessionForListings = YES;
    
    if(self.existing) {
        self.providers = @[[GoogleDriveStorageProvider sharedInstance],
                           [DropboxV2StorageProvider sharedInstance],
                           [OneDriveStorageProvider sharedInstance],
                           webDavProvider,
                           sftpProviderWithFastListing,
                           [LocalDeviceStorageProvider sharedInstance]];
    }
    else {
        if ([Settings sharedInstance].iCloudOn) {
            self.providers = @[[AppleICloudProvider sharedInstance],
                               [GoogleDriveStorageProvider sharedInstance],
                               [DropboxV2StorageProvider sharedInstance],
                               [OneDriveStorageProvider sharedInstance],
                               webDavProvider,
                               sftpProviderWithFastListing,
                               [LocalDeviceStorageProvider sharedInstance]];
        }
        else {
            self.providers = @[[GoogleDriveStorageProvider sharedInstance],
                               [DropboxV2StorageProvider sharedInstance],
                               [OneDriveStorageProvider sharedInstance],
                               webDavProvider,
                               sftpProviderWithFastListing,
                               [LocalDeviceStorageProvider sharedInstance]];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.providers.count + (self.existing ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomStorageProviderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storageProviderReuseIdentifier" forIndexPath:indexPath];
    
    if(indexPath.row == self.providers.count) {
        cell.text.text = @"Copy from URL...";
        cell.image.image =  [UIImage imageNamed:@"Disconnect-32x32"];
    }
    else {
        id<SafeStorageProvider> provider = [self.providers objectAtIndex:indexPath.row];

        cell.text.text = provider.displayName;
        cell.image.image = [UIImage imageNamed:provider.icon];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == self.providers.count) {
        [self initiateManualImportFromUrl];
    }
    else {
        id<SafeStorageProvider> provider = [_providers objectAtIndex:indexPath.row];
        if (provider.storageId == kLocalDevice && !self.existing) {
            [Alerts yesNo:self
                    title:@"Local Device Safe Caveat"
                  message:@"Since a local safe is only stored on this device, any loss of this device will lead to the loss of "
             "all passwords stored within this safe. You may want to consider using a cloud storage provider, such as the ones "
             "supported by Strongbox to avoid catastrophic data loss.\n\nWould you still like to proceed with creating "
             "a local device safe?"
                   action:^(BOOL response) {
                       if (response) {
                           [self segueToBrowserOrAdd:provider];
                       }
                       else {
                           [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                       }
                   }];
        }
        else {
            [self segueToBrowserOrAdd:provider];
        }
    }
}

- (void)segueToBrowserOrAdd:(id<SafeStorageProvider>)provider {
    if ((self.existing && provider.browsableExisting) || (!self.existing && provider.browsableNew)) {
        [self performSegueWithIdentifier:@"SegueToBrowser" sender:provider];
    }
    else {
        AddSafeAlertController *controller = [[AddSafeAlertController alloc] init];
        
        [controller addNew:self
                validation:^BOOL (NSString *name, NSString *password) {
                    return [[SafesList sharedInstance] isValidNickName:name] && password.length;
                }
                completion:^(NSString *name, NSString *password, BOOL response) {
                    if (response) {
                        NSString *nickName = [SafesList sanitizeSafeNickName:name];
                        
                        [AddNewSafeHelper addNewSafeAndPopToRoot:self name:nickName password:password provider:provider format:self.format];
                    }
                }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SegueToBrowser"]) {
        StorageBrowserTableViewController *vc = segue.destinationViewController;
        
        vc.existing = self.existing;
        
        NSLog(@"Setting Storage Browser FOrmat: %d", self.format);
        
        vc.format = self.format;
        vc.safeStorageProvider = sender;
        vc.parentFolder = nil;
    }
}

- (void)initiateManualImportFromUrl {
    [Alerts OkCancelWithTextField:self
             textFieldPlaceHolder:@"URL"
                            title:@"Enter URL"
                          message:@"Please Enter the URL of the Safe File."
                       completion:^(NSString *text, BOOL response) {
                           if (response) {
                               NSURL *url = [NSURL URLWithString:text];
                               NSLog(@"URL: %@", url);
                               
                               [self importFromManualUiUrl:url];
                           }
                       }];
}

- (void)importFromManualUiUrl:(NSURL *)importURL {
    NSError* error;
    NSData *importedData = [NSData dataWithContentsOfURL:importURL options:kNilOptions error:&error];
    
    if(error) {
        [Alerts error:self title:@"Error Reading from URL" error:error];
        return;
    }
    
    if (![DatabaseModel isAValidSafe:importedData error:&error]) {
        [Alerts error:self
                title:@"Invalid Safe"
                error:error];
        
        return;
    }
    
    [self promptForImportedSafeNickName:importedData];
}

- (void)promptForImportedSafeNickName:(NSData *)data {
    [Alerts OkCancelWithTextField:self
             textFieldPlaceHolder:@"Safe Name"
                            title:@"Enter a Name"
                          message:@"What would you like to call this safe?"
                       completion:^(NSString *text, BOOL response) {
                           if (response) {
                               NSString *nickName = [SafesList sanitizeSafeNickName:text];
                               
                               if (![[SafesList sharedInstance] isValidNickName:nickName]) {
                                   [Alerts   info:self
                                            title:@"Invalid Nickname"
                                          message:@"That nickname may already exist, or is invalid, please try a different nickname."
                                       completion:^{
                                           [self promptForImportedSafeNickName:data];
                                       }];
                               }
                               else {
                                   [self copyAndAddImportedSafe:nickName data:data];
                               }
                           }
                       }];
}

- (void)copyAndAddImportedSafe:(NSString *)nickName data:(NSData *)data {
    id<SafeStorageProvider> provider;
    
    if(Settings.sharedInstance.iCloudOn) {
        provider = AppleICloudProvider.sharedInstance;
    }
    else {
        provider = LocalDeviceStorageProvider.sharedInstance;
    }
    
    NSString* extension = [DatabaseModel getLikelyFileExtension:data];
    
    [provider create:nickName
           extension:extension
                data:data
        parentFolder:nil
      viewController:self
          completion:^(SafeMetaData *metadata, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^(void)
                        {
                            if (error == nil) {
                                [[SafesList sharedInstance] addWithDuplicateCheck:metadata];
                            }
                            else {
                                [Alerts error:self title:@"Error Importing Safe" error:error];
                            }
                            
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        });
     }];
}


@end
