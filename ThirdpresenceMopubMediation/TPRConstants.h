/*!
 
 @header TPRConstants.h
 
 This file contains common constants used in Thirdpresence Mopub mediation adapter
 
 @author Marko Okkonen
 @copyright 2016 Thirdpresence
 
 */

#import <Foundation/Foundation.h>

/*!
 @brief Targeting key for user's year of birth
 */
FOUNDATION_EXPORT NSString *const TPR_MP_TARGETING_PARAM_YOB;

/*!
 @brief Targeting key for user's gender. 
 @discussion The value shall be either "male" or "female".
 */
FOUNDATION_EXPORT NSString *const TPR_MP_TARGETING_PARAM_GENDER;

/*!
 @brief Targeting key for keywords
 @discussion The value shall be a comma separated string of words.
 */
FOUNDATION_EXPORT NSString *const TPR_MP_TARGETING_PARAM_KEYWORDS;

// internal
FOUNDATION_EXPORT NSString *const TPR_MP_PUB_PARAM_ACCOUNT;
// internal
FOUNDATION_EXPORT NSString *const TPR_MP_PUB_PARAM_PLACEMENT_ID;
