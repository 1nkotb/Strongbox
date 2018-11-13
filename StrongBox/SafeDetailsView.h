//
//  SafeDetailsView.h
//  StrongBox
//
//  Created by Mark on 09/09/2017.
//  Copyright © 2017 Mark McGuill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface SafeDetailsView : UITableViewController

@property (nonatomic, nonnull) Model *viewModel;

@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelNumberOfGroups;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelNumberOfRecords;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelNumberOfUniqueUsernames;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelNumberOfUniquePasswords;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelMostPopularUsername;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelNumberOfUniqueEmails;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelMostPopularEmail;

@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelToggleOfflineCache;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelExportByEmail;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelToggleTouchId;
@property (weak, nonatomic) IBOutlet UILabel * _Nullable labelChangeMasterPassword;

@property (weak, nonatomic) IBOutlet UILabel *labelToggleAutoFillCache;

@end
