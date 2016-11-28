//
//  Key.swift
//  FAVE
//
//  Created by Nazih Shoura on 30/06/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import Firebase
import MidtransKit

struct Keys {
    var BaseURLString: String {
        switch appDefault.mode {
        case .Release:
            return "https://api.myfave.com"
        case .Staging:
            return "http://staging.app.kfit.com"
        case .Staging2:
            return "http://staging2.app.kfit.com"
        case .Staging3:
            return "http://staging3.app.kfit.com"
        case .Staging4:
            return "http://staging4.app.kfit.com"
        case .Staging5:
            return "http://staging5.app.kfit.com"
        case .Whack:
            return "http://whack.dev.kfit.ninja"
        case .Echo:
            return "http://echo.dev.kfit.ninja"
        }
    }

    var BundleIDString: String {
        return appDefault.mode.isRelease ?
            "com.kfit.fave"
            : "com.kfit.fave.dev"
    }
    var MessageNotificationIdentifier: String {
        return "MessageNotificationIdentifier"
    }
    var ReminderNotificationIdentifier: String {
        return "ReminderNotificationIdentifier"
    }
    var ReminderNotificationActionIdentifier: String {
        return "ReminderNotificationActionIdentifier"
    }

    var GooglePlaceKey: String {
        return appDefault.mode.isRelease ?
        "AIzaSyC9HrFSkNTuOuLs7usjOIqmP4kEbhQM_Lk"
        : "AIzaSyDfVKS25oF0d56DSAP05XA2abJW5OgwcAU"
    }

    var AdyenToken: String {
        return appDefault.mode.isRelease ?
        "2614688111030034"
        : "7614696429845695"
    }

    var GoogleAPI: String {
        return appDefault.mode.isRelease ?
            "AIzaSyCBO3dbyugh8hkaGDWP6gnoBAyqcyP1HjY"
            : "AIzaSyBBwk9cgNp7fEMBCFNJpaE0h6k_QbO-qtk"
    }

    var firebaseOptions: FIROptions {
        return appDefault.mode.isRelease ?
            FIROptions(contentsOfFile: NSBundle.mainBundle().pathForResource("GoogleService-Info", ofType: "plist")) :
        FIROptions(contentsOfFile: NSBundle.mainBundle().pathForResource("GoogleService-Debug-Info", ofType: "plist"))
    }

    var firebaseAPNSTokenType: FIRInstanceIDAPNSTokenType {
        return appDefault.mode.isRelease ?
        FIRInstanceIDAPNSTokenType.Prod :
        FIRInstanceIDAPNSTokenType.Sandbox
    }

    var AppleAppID: String {
        return appDefault.mode.isRelease ?
        "1135179082"
        : "1135364327"
    }

    var AppsFlyerDevKey: String {
        return "bXvgGLzoHU46TyDTU6vFJh"
    }

    var MoEngageAppId: String {
        return "948SFHYW7IFX0Y0PRK4QP6R8"
    }

    var LocalyticsProdApiKey: String {
        return "e55f7bb8ca49dbab0a1ca1b-194e3020-6fa9-11e6-4410-00f573af1d63"
    }

    var LocalyticsDevApiKey: String {
        return "f100bf861a38c5d4b682bdf-0a0f61ae-6fa9-11e6-f745-00ae30fe7875"
    }

    var ZopimAccountKey: String {
        return "3w9u6ryRvgAo7i6UyFTwWcoKiTeZp6E2"
    }

    var SendBirdAppId: String {
        return appDefault.mode.isRelease ?
            "CA0CFED1-F64C-4363-B240-B58713BD60FF"
            : "BA44116E-6741-419B-861F-E93E10355B77"
    }

    var LocalyticsAppKey: String {
        return appDefault.mode.isRelease ?
            "e55f7bb8ca49dbab0a1ca1b-194e3020-6fa9-11e6-4410-00f573af1d63"
            : "f100bf861a38c5d4b682bdf-0a0f61ae-6fa9-11e6-f745-00ae30fe7875"
    }

    var facebookURLDeeplink: String {
        return "fb://profile/1119487964739134"
    }

    var facebookURL: String {
        return "http://www.facebook.com/1119487964739134"
    }

    var instagramURLDeeplink: String {
        return "instagram://user?username=fave.official"
    }

    var instagramURL: String {
        return "http://instagram.com/fave.official"
    }

    var VERITRANS_MERCHANT_BASE_URL_String: String {
        let URL = self.BaseURLString + "/api/fave/v2/cities/jakarta/veritrans"
        return URL
    }

    var VERITRANS_MERCHANT_CLIENT_KEY: String {
        return appDefault.mode.isRelease ?
            "VT-client-6cY-Ure5v38pbh4T"
            : "VT-client-TzAbiyRrkIP_IkqY"
    }

    var VT_SERVER_ENVIRONMENT: MIdtransServerEnvironment {
        return appDefault.mode.isRelease ?
            MIdtransServerEnvironment.Production
            : MIdtransServerEnvironment.Sandbox
    }

    var ZendeskAppId: String {
        return "a58d6083c5bfaaf9ff1a9fc6c958a6e320d07bda6b807fb1"
    }

    var ZendeskClientId: String {
        return "mobile_sdk_client_89a16601d7ea0dd3e0c3"
    }

    var ZendeskURL: String {
        switch settingsProviderDefault.settings.value.appCompany {
        case .groupon: return "https://faveindonesia.zendesk.com"
        case .kfit: return "https://fave.zendesk.com"
        }
    }

    var ZendeskDepartment: String {
        switch settingsProviderDefault.settings.value.appCompany {
        case .groupon: return "Jakarta Team"
        case .kfit: return "KL HQ"
        }
    }

}
