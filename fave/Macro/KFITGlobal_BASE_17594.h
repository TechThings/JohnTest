//
//  KFITGlobal.h
//  KFIT
//
//  Created by KFIT on 4/29/15.
//  Copyright (c) 2015 kfit. All rights reserved.
//

#ifndef KFIT_KFITGlobal_h
#define KFIT_KFITGlobal_h

#ifdef STAGING
    #define kKFITBaseURL                    @"http://beta.app.kfit.com"
//    #define kKFITBaseURL                    @"http://staging.app.kfit.com"
    //#define kKFITBaseURL                    @"http://localhost:8080"
    #define kKFITLocalyticsAppKey           @"3f39b2d04632a4caa26c1a7-8be2377c-6cc1-11e5-b310-00d0fea82624"
    #define kKFITStagingLocalyticsAppKey    @"3f39b2d04632a4caa26c1a7-8be2377c-6cc1-11e5-b310-00d0fea82624"
    #define kKFITFacebookURLScheme          @"fb892822657443029"
    #define AppsFlyerDevKey                 @"bXvgGLzoHU46TyDTU6vFJh"
    #define KFITAppId                       @"1004405993"

    #define SegmentIOWriteKeyDev            @"TK5wrcASDcLvvgJiY1soRJUB09jiiGXp"
    #define SegmentIOWriteKeyStaging        @"TK5wrcASDcLvvgJiY1soRJUB09jiiGXp"
    #define SegmentIOWriteKeyProduction     @"TK5wrcASDcLvvgJiY1soRJUB09jiiGXp"

    #define IntercomAppID                   @"b7ttr9m8"
    #define IntercomAPIKey                  @"ios_sdk-2d8b8214591b2bb9b2668170f971e7ac47c2c4c5"
    #define IntercomAppIDProduction         @"b7ttr9m8"
    #define IntercomAPIKeyProduction        @"ios_sdk-2d8b8214591b2bb9b2668170f971e7ac47c2c4c5"
    #define OptimizelyKey                   @"AAM7hIkBicEmsUVxyiz1-jazzgTCxjKy~3461270009"
    #define KFITBrainTreeScheme             @"com.kfit.KFIT.dev.payments"
    #define kKFITURLScheme                  @"kfitdev"
#else
    #define kKFITBaseURL                    @"https://access.kfit.com"
    #define kKFITLocalyticsAppKey           @"9b42ab60a100a939ae5364f-367aaa6c-674a-11e5-7464-00736b041834"
    #define kKFITStagingLocalyticsAppKey    @"9b42ab60a100a939ae5364f-367aaa6c-674a-11e5-7464-00736b041834"
    #define kKFITFacebookURLScheme          @"fb892117890846839"
    #define AppsFlyerDevKey                 @"bXvgGLzoHU46TyDTU6vFJh"
    #define KFITAppId                       @"1004405993"

    #define SegmentIOWriteKeyDev            @"TK5wrcASDcLvvgJiY1soRJUB09jiiGXp"
    #define SegmentIOWriteKeyStaging        @"TK5wrcASDcLvvgJiY1soRJUB09jiiGXp"
    #define SegmentIOWriteKeyProduction     @"HUO8AKiqdAiBXUffQt1Aep84mYIWLa9t"

    #define IntercomAppID                   @"b7ttr9m8"
    #define IntercomAPIKey                  @"ios_sdk-2d8b8214591b2bb9b2668170f971e7ac47c2c4c5"
    #define IntercomAppIDProduction         @"jwnmrksc"
    #define IntercomAPIKeyProduction        @"ios_sdk-14f97a50243a58cec0fa96ddd0125b2ab86e7da0"
    #define OptimizelyKey                   @"AAM7hIkBicEmsUVxyiz1-jazzgTCxjKy~3461270009"
    #define KFITBrainTreeScheme             @"com.kfit.KFIT.payments"
    #define kKFITURLScheme                  @"kfit"
#endif

#define INTERCOM_KEY                        @"intercom_sdk"
#define INTERCOM_URI                        @"uri"
#define INTERCOM_RECEIVER                   @"receiver"


#define CLCOORDINATE_EPSILON 0.005f
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

#define KFITShowPastActivityTableViewCellIdentifier                @"KFITShowPastActivityTableViewCell"
#define KFITAppDesc                             @"KFit - Fitness for Everyone"
#define kKFITActiveNaviControllerObserver       @"activeNavigationController"
#define kKFITActiveStoryboardObserver           @"activeStoryboard"
#define kKFITActiveViewControllerObserver       @"activeViewController"
#define kKFITUsernameTableViewCell              @"KFITUsernameTableViewCell"
#define kKFITPasswordTableViewCell              @"KFITPasswordTableViewCell"
#define kKFITLoginButtonTableViewCell           @"KFITLoginButtonTableViewCell"
#define kKFITForgotPasswordButtonTableViewCell  @"KFITForgotPasswordButtonTableViewCell"
#define kKFITFirstInstall                       @"kKFITFirstInstall"
#define kKFITCitiesAvailable                    @"kKFITCitiesAvailable"
#define kKFITCookies                            @"kKFITCookies"
#define kKFITSkipLoginAtTutorial                @"kKFITSkipLoginAtTutorial"
#define kKFITAllActivities                      NSLocalizedString(@"all",nil)
#define kKFITAllLocations                       NSLocalizedStringFromTable(@"All Locations", @"LocalizableUnmanaged", nil)
#define kKFITReserveLoadingString               NSLocalizedStringFromTable(@"Loading activities", @"LocalizableUnmanaged", nil)
#define kKFITUserLocationPermission             @"com.kfit.KFIT.userLocationPermission"
#define kKFITMainCategoryFilterTableViewCell @"KFITMainCategoryFilterTableViewCell"
#define kKFITUserLocation                       @"com.kfit.KFIT.userLocation"

#define kKFITMyReservsation                     @"KFITMyReservsation"
#define kKFITReservationConfirmed               @"confirmed"
#define kKFITReservationNoShow                  @"notshown"
#define kKFITReservationCancelled               @"cancelled"
#define kKFITGetReviewedActivities              @NO
#define kKFITSearchPerPage                      @15
#define kKFITPartnerCache                       @"KFITPartnerCache"
#define kKFITOutletMapCache                     @"KFITOutletMapCache"

#define kKFITTownsCache                         @"kKFITTownsCache"
#define kKFITCitiessCache                       @"kKFITCitiessCache"
#define kKFITCountriesCache                     @"kKFITCountriesCache"
#define kKFITPlansCache                         @"kKFITPlansCache"
#define kKFITMemberPlanUpgrade                  @"KFITMemberPlanUpgrade"
#define kKFITUpdateCurrentSegueNotification     @"KFITUpdateCurrentSegueNotification"
#define kKFITReserveActivityAction              @"KFITReserveActivityAction"
#define kKFITReserveActivityUpgrade             @"kKFITReserveActivityUpgrade"
#define kKFITReservedActivtyActionNotification  @"KFITReservedActivty"
#define kKFITDismissSignUpMainNotification      @"kkFITSignUpMainDidDismiss"
#define kKFITNotificationForCancelActivity      @"KFITNotificationForCancelActivity"
#define kKFITClearCache                         @"com.kfit.KFIT.clearCache"
#define kKFITPartnerDeepLinking                 @"com.kfit.partners.deeplinking"
#define kKFITScheduleDeepLinking                @"com.kfit.schedules.deeplinking"
#define kKFITLastExpandedSection @"KFITLastExpandedSection"

#define kKFITRefreshMoreNowNotification         @"kKFITRefreshMoreNowNotification"
#define kKFITRefreshScheduleNotification        @"kKFITRefreshScheduleNotification"
#define kKFITMemberRecievedNotification         @"kKFITMemberRecievedNotification"
#define kKFITFilterBeingConstructedDidUpdateNotification @"KFITFilterManager.filterBeingConstructedDidUpdate"
#define kKFITFilterMasterDidUpdateNotification @"KFITFilterManager.filterMasterDidUpdate"
#define kKFITInternalRefreshScheduleNotification @"kKFITInternalRefreshScheduleNotification"
#define kKFITRefreshPartersNotification         @"kKFITRefreshPartersNotification"
#define kKFITReloadSettingsViewController       @"kKFITReloadSettingsViewController"
#define kKFITRefreshCategoryListNotification    @"kKFITRefreshCategoryListNotification"
#define kKFITRefreshPartersListNotification     @"kKFITRefreshPartersListNotification"
#define kKFITDismissPlanNotification            @"kKFITDismissPlanNotification"
#define kKFITLogOutNotification                 @"kKFITLogOutNotification"

#define kKFITSubmitReview                       @"KFITSubmitReview"
#define kKFITReviewAction                       @"KFITReviewAction"
#define kKFITReminderLocalNotificationCategory  @"KFITReminderLocalNotificationCategory"
#define kKFITReminderAction                     @"KFITReminderAction"
#define kKFITReviewListAchieve                  @"KFITReviewListAchieve"
#define kKFITReminderListAchieve                @"KFITReminderListAchieve"
#define kKFITReminderActivation                 @"KFITReminderActivation"
#define kKFITStatsIdentifier                    @"KFITStatsIdentifier"
#define kKFITEvents                             @"KFITCalendarEvents"

#define kKFITOptimizelyURLScheme                @"optly3461270009"
#define kKFITPushNotification                   @"deeplink"
#define kKFITPushURL                            @"openURL"
#define kKFITDeepLinkPath                       @"$deeplink_path"
#define kKFITOptimizelyKey                      @"AAM7hIkBicEmsUVxyiz1-jazzgTCxjKy~3461270009"
#define kKFITOptimizelyImagePrefix              @"LAUNCH_BACKGROUND_IMAGEVIEW_"

#define kKFITPaymentClientToken                 @"/api/payments/client_token"
#define kKFITDowngrade(user_id)                 [NSString stringWithFormat:@"/api/subscriptions/%zd/downgrade", user_id]
#define kKFITPayment                            @"/api/payments"
#define kKFITPaymentV3                          @"/api/v3/payments"
#define kKFITReceipts                           @"/api/v3/receipts"
#define kKFITPaymentPlan                        @"/api/paymentsPlan"
#define kKFITPaymentMethod                      @"/api/v3/payments/methods"
#define kKFITTrackUserLocation                  @"/api/users/location"
#define kKFITSession                            @"/api/sessions"
#define kKFITCategory                           @"/api/v3/categories"
#define kKFITCompany                            @"/api/v2/companies"
#define kKFITOutlets                            @"/api/outlets/"
#define kKFITReserve                            @"/api/v3/reservations"
#define kKFITCurrentReserve                     @"/api/v3/reservations/current"
#define kKFITPastReserve                        @"/api/v3/reservations/past"
#define kKFITSubscribe                          @"/api/v3/subscriptions"

#define kKFITReview                             @"/api/v3/reviews"
#define kKFITStats                              @"/api/stats"
#define kKFITSearch                             @"api/v2/searches"
#define kKFITCountries                          @"/api/countries"
#define kKFITTown                               @"/api/towns"
#define kKFITSubscriptionPlans                  @"/api/subscription_plans"

#define kKFITForgotPassword                     @"/password_recovery/new"
#define kKFITSignUp                             @"/api/users"
#define kKFITCredits                            @"/api/v3/users/credits"
#define kKFITSignUpStatus                       @"/api/users/status"
#define kKFITSignUpOauth                        @"/api/users/oauth_signup"
#define kKFITSigninOauth                        @"/api/users/oauth_signin"
#define kKFITSelectedCity                       @"/api/users/selected_city"
#define kKFITUpdateUserProfile                  @"/api/v2/profiles"
#define kKFITCurrent                            @"/api/users/current"
#define kKFITAbsence                            @"/api/v2/absence_penalties/notify"
#define kKFITPromocode                          @"/api/users/promo_code"
#define kKFITPromoCode(promocode)               [NSString stringWithFormat:@"/api/promo_codes/%@", promocode]
#define kKFITPromoCodePlan(promocode)           [NSString stringWithFormat:@"/api/v2/promo_codes/%@", promocode]
#define kKFITPartnersReview(id)                 [NSString stringWithFormat:@"/api/companies/%@/reviews", id]
#define kKFITPartner(id)                        [NSString stringWithFormat:@"/api/v2/companies/%@", id]
#define kKFITTimePromo                          @"/api/v3/time_promotions"
#define kKFITBanners                            @"/api/v3/mobile_banners"

#define kKFITCancel                             @"/api/v3/reservations/%@/cancel"
#define kKFITCancellationInfo                   @"/api/v3/reservations/%@/cancellation_info"
#define kKFITBrainTreeScheme                    @"com.kfit.KFIT.payments"
#define kKFITDateSchedule                       @"/api/schedules/"

#define KFITFavorite                            @"/api/v3/favorites"
#define KFITDeleteFavorite(favoriteId)          [NSString stringWithFormat:@"/api/v3/favorites/%@", favoriteId]
#define kKFITV3Schedule                         @"/api/v3/schedules"
#define kKFITV3Outlets                          @"/api/v3/outlets"
#define kKFITFilters                            @"/api/v2/filters"
#define kKFITV3Filters                          @"/api/v2/filters"
#define kKFITShowProgressHUD                    @"com.kfit.KFIT.ShowProgressHUD"
#define KFITUserPassActivityTableViewCell   @"KFITUserPassActivityTableViewCell"
#define kKFITNextDay                            @"com.kfit.KFIT.NextDay"
#define kKFITPreviousDay                        @"com.kfit.KFIT.PreviousDay"
#define kKFITReservationAddedNotification       @"com.kfit.KFIT.ReservationNetworkManagerAdded"
#define kKFITScheduleAddedNotification          @"com.kfit.KFIT.ScheduleNetworkManagerAdded"
#define kKFITCategoryAddedNotification          @"com.kfit.KFIT.ActivityCategoryNetworkManagerAdded"
#define kKFITStatsAddedNotification             @"com.kfit.KFIT.StatsNetworkManagerAdded"
#define kKFITPartnerAddedNotification           @"com.kfit.KFIT.PartnerNetworkManagerAdded"
#define kKFITMapPartnerAddedNotification        @"com.kfit.KFIT.MapPartnerNetworkManagerAdded"
#define kKFITUserNotificationPermissionViewController @"KFITUserNotificationPermissionViewController"
#define kKFITLocationPermissionViewController  @"KFITLocationPermissionViewController"
#define KFITHasPromptedForUserNotification      @"KFITHasPromptedForUserNotification"
#define kKFITTagFilterCollectionViewCell         @"KFITTagFilterCollectionViewCell"
#define kKFITActivityCollectionViewHeaderView    @"KFITActivityCollectionViewHeaderView"
#define kKFITActivityCollectionViewFooterView    @"KFITActivityCollectionViewFooterView"
#define kKFITTitleViewCollectionReusableView     @"KFITTitleViewCollectionReusableView"
#define kKFITMainCategoryFilterCollectionViewCell @"KFITMainCategoryFilterCollectionViewCell"
#define kKFITOnBoardingActivitySelectionCollectionViewHeaderView  @"KFITOnBoardingActivitySelectionCollectionViewHeaderView"
#define kKFITLoadMoreCollectionViewCell @"KFITLoadMoreCollectionViewCell"
#define kKFITCategoryFilterCollectionViewCell   @"KFITCategoryFilterCollectionViewCell"
#define kKFITMemberAddedNotification            @"com.kfit.KFIT.MemberNetworkManagerAdded"
#define KFITCurrentDateNotification             @"KFITCurrentDateNotification"
#define kKFITCompanyWithId(companyIdNumber)            [NSString stringWithFormat:@"%@/%zd",kKFITCompany,[companyIdNumber integerValue]];
#define kKFITUpdateFilterMasterForUpdatedCityNotification @"kKFITUpdateFilterMasterForUpdatedCityNotification"
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and   iPod touch style UI
#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)
#define IS_IPHONE_5_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 667.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)
#define IS_IPHONE_5_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 667.0f)

#define IS_IPHONE_5 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_IOS8 : IS_IPHONE_5_IOS7 )
#define IS_IPHONE_6 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6_IOS8 : IS_IPHONE_6_IOS7 )
#define IS_IPHONE_6P ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6P_IOS8 : IS_IPHONE_6P_IOS7 )
#define IS_IPHONE_4_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_4_AND_OLDER_IOS8 : IS_IPHONE_4_AND_OLDER_IOS7 )
#define IS_IPHONE_5_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_AND_OLDER_IOS8 : IS_IPHONE_5_AND_OLDER_IOS7 )

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIGradientColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.2]

#define NUMBER_OF_PAGES 3
#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page))
#define RAND_FROM_TO(min, max) [NSNumber numberWithInt:rand() % ([max intValue] - [min intValue]) + [min intValue]];


#define kFITFaqURL @"http://access.kfit.com/faq-mobile"
#define kFITBlogURL @"http://blog.kfit.com"
#define kFITQuizURL @"http://www.kfit.com/fitquiz"

static NSString *const kKeychainItemName            = @"Google Calendar";
static NSString *const kClientID                    = @"15862641269-rpd65fj1jmud1jvtrfph18luhd3cdvfv.apps.googleusercontent.com";
static NSString *const kClientSecret                = @"TL6etbM5e0AYP8_gec_0jIRh";
static NSString *const InputValidationErrorDomain   = @"InputValidationErrorDomain";
static NSString *const ResponseValidationErrorDomain   = @"ResponseValidationErrorDomain";
static NSString *const KFITErrorDomain              = @"KFITErrorDomain";

static NSInteger const kkFITOutletMapZoomLevel      = 15;
static NSInteger const kkFITOutletMapZoomOutLevel   = 11;
static NSInteger const kkFITUserMapZoomLevel        = 14;


#define KFITUsernameErrorCode 1001
#define KFITPasswrodErrorCode 1001
#define KFITResponseNotMatchErrorCode 1001
#define KFITIncompatibleRequestParameters 1003
#define KFITLoadingNotAllowedCode 1004

#endif
