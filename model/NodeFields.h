//
//  NodeFields.h
//  MacBox
//
//  Created by Mark on 31/08/2017.
//  Copyright © 2017 Mark McGuill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasswordHistory.h"

@interface NodeFields : NSObject

- (instancetype _Nullable)init;

- (instancetype _Nullable)initWithUsername:(NSString*_Nonnull)username
                                       url:(NSString*_Nonnull)url
                                  password:(NSString*_Nonnull)password
                                     notes:(NSString*_Nonnull)notes
                                     email:(NSString*_Nonnull)email NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, nonnull) NSString *password;
@property (nonatomic, strong, nonnull) NSString *username;
@property (nonatomic, strong, nonnull) NSString *email;     // TODO: Not used by Keepass at all
@property (nonatomic, strong, nonnull) NSString *url;
@property (nonatomic, strong, nonnull) NSString *notes;
@property (nonatomic, retain, nonnull) PasswordHistory *passwordHistory; // TODO: make pwsafe and KeePass compatible
@property (nonatomic, strong, nullable) NSDate *created;
@property (nonatomic, strong, nullable) NSDate *modified;
@property (nonatomic, strong, nullable) NSDate *accessed;
@property (nonatomic, strong, nullable) NSDate *passwordModified; // TODO: This isn't in Keepass - Find a way to resolve

@end
