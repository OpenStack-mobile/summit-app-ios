//
//  MySpotlightImporter.h
//  SpotlightImporter
//
//  Created by Alsey Coleman Miller on 2/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define YOUR_STORE_TYPE NSXMLStoreType

@interface MySpotlightImporter : NSObject

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (BOOL)importFileAtPath:(NSString *)filePath attributes:(NSMutableDictionary *)attributes error:(NSError **)error;

@end
