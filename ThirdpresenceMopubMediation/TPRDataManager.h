/*!
 
 @header TPRDataManager.h
 
 This file contains TPRDataManager class declaration.
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import <Foundation/Foundation.h>
#import "TPRConstants.h"

/*!
 * @brief TPRDataManager is a singleton class that is used to hold data (e.g. targeting) to be used with the Thirdpresence Ad SDK.
 */
@interface TPRDataManager : NSObject

/*!
 @brief Gets singleton instance of the data manager
 */
+ (id)sharedManager;

/*!
 @brief a dictionary containing targeting data
 @discussion see TPRContants.h for available keys for targeting 
 */
@property (nonatomic, strong) NSMutableDictionary* targeting;

@end
