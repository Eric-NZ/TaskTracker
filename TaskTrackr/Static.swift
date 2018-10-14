//
//  Constants.swift
//  TaskTrackr
//
//  Created by Eric Ho on 4/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import Foundation
import Toaster
import RealmSwift

struct Static {
    // **** Realm Cloud Users:
    // **** Replace MY_INSTANCE_ADDRESS with the hostname of your cloud instance
    // **** e.g., "mycoolapp.us1.cloud.realm.io"
    // ****
    // ****
    // **** ROS On-Premises Users
    // **** Replace the AUTH_URL string with the fully qualified versions of
    // **** address of your ROS server, e.g.: "http://127.0.0.1:9080"
    
    static let MY_INSTANCE_ADDRESS = "tasktrackr.us1a.cloud.realm.io" // <- update this
    
    static let AUTH_URL  = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/TaskTrackr")!
    
    // user status: has signed in?
    static var currentUser: SyncUser?
    
    static let page_service = "ServiceViewController"
    static let page_worker = "WorkerViewController"
    static let page_product = "ProductViewController"
    static let page_tool = "ToolViewController"
    static let page_site = "SiteViewController"
    static let pageRouter = "RootPagingViewController"
    
    static let segue_openServiceForm = "OpenServiceForm"
    static let segue_openWorkerForm = "OpenWorkerForm"
    static let segue_openProductForm = "OpenProductForm"
    static let segue_openToolForm = "OpenToolForm"
    static let segue_openSiteForm = "OpenSiteForm"
    static let segue_openProductSelector = "OpenPickupController"
    static let segue_openTaskEditor = "OpenTaskEditor"
    static let segue_openWorkerPicker = "OpenWorkerPicker"
    static let segue_openServicePicker = "OpenServicePicker"
    static let segue_openLocationSelector = "OpenLocationSelector"
    static let segue_openPicturePicker = "OpenPicturePicker"
    
    static let none_selected = "None Selected"
    static let address_required = "Not Set"
    
    // Users' location latitude and longtitude
    static let userLocationDegree = (-36.848461, 174.763336)    // Auckland
    // 400KM
    static let regionSpan = (400000.00, 400000.00)
    
    static func showToast(toastText: String) {
        Toast(text: toastText, delay: 0, duration: Delay.long).show()
    }
    
    /*
     static: Get Instance of UIViewController using storyboard identifier.
     */
    static func getInstance(with indentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: indentifier)
    }
}
