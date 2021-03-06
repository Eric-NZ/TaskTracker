//
//  DatabaseService.swift
//  TaskTrackr
//
//  Created by Eric Ho on 3/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func resultToArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        
        return array
    }
}

class DatabaseService {
    static var shared = DatabaseService()
    var realmUrl: URL = Static.REALM_URL
    var realm: Realm?
    
    enum objectType {
        case service, worker, product, tool, site
    }
    
    init() {}
    
    func getRealm() -> Realm {
        return self.realm!
    }
    
    func setRealm(for user: SyncUser){
        var realm: Realm?
        let configure = user.configuration(realmURL: Static.REALM_URL, fullSynchronization: true, enableSSLValidation: false, urlPrefix: nil)
        try! realm = Realm(configuration: configure)
        
        self.realm = realm!
    }
    
    /** Once data for sections changed, controller will be notified.
     // This function includes callback
     */
    func addNotificationHandleForSections<T>(objects: Results<T>, tableView: UITableView?, callback: (()->Void)?) -> NotificationToken {
        let notificationToken = objects.observe { (changes) in
            switch changes {
            case .initial:
                tableView!.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                // before beginUpdates, invoke call back to inform client view controller
                if let callback = callback {
                    callback()
                }
                // begin updates
                tableView!.beginUpdates()
                // update sections
                tableView!.insertSections(IndexSet(insertions.map({
                    return $0
                })), with: .automatic)
                tableView!.deleteSections(IndexSet(deletions.map({
                    return $0
                })), with: .automatic)
                tableView!.reloadSections(IndexSet(modifications.map({
                    return $0
                })), with: .automatic)
                tableView!.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
        return notificationToken
    }
    
    /** Once data for rows changed, controller will be notified.
     // But: how to do when changing sections?
     */
    func addNotificationHandleForRows<T>(objects: Results<T>, tableView: UITableView?) -> NotificationToken {
        
        let notificationToken = objects.observe { (changes) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView!.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView!.beginUpdates()
                // update rows
                tableView!.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                      with: .automatic)
                tableView!.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                      with: .automatic)
                tableView!.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                      with: .automatic)
                tableView!.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        return notificationToken
    }
    
    public func objectListToArray<T>(from list: List<T>) -> [T] {
        var array: [T] = []
        array.append(contentsOf: list)
        
        return array
    }
    
    // get object array, this function is not working for model objects.
    public func getObjectArray(objectType: Object.Type) -> [Object] {
        let realm = getRealm()
        return realm.objects(objectType).resultToArray(ofType: objectType)
    }

    // remove a single object
    public func removeObject(object: Object) {
        let realm = getRealm()
        try! realm.write {
            realm.delete(object)
        }
    }
    
    // remove objects using key precidate
    public func removeObjects(objectType: Object.Type, with precidate: NSPredicate?) {
        let realm = getRealm()
        let toRemove = realm.objects(objectType).filter(precidate!)
        try! realm.write {
            realm.delete(toRemove)
        }
    }
    
    // add a single object
    public func addObject(for object: Object) {
        let realm = getRealm()
        try! realm.write {
            realm.add(object)
        }
    }
    
    // update an existing object
    func updateObject(for object: Object, with keyValues: [String: String]) {
        let realm = getRealm()
        try! realm.write {
            //
        }
    }
    
    // destArray(B) is a sub set of source2DArray(A), this function returns an indices where A contains elememts from B
    func mappingSegregatedIndices(wholeMatrix: [[Object]], elements: [Object]) -> [[Int]]{
        var indices: [[Int]] = []
        
        let numberOfSections = wholeMatrix.count
        for section in 0..<numberOfSections {
            indices.append([])
            let numberOfRowsInSection = wholeMatrix[section].count
            for row in 0..<numberOfRowsInSection {
                if elements.contains(wholeMatrix[section][row]) {
                    indices[section].append(row)
                }
            }
        }
        
        return indices
    }
}
