//
//  ProductsTableViewController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 6/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit
import RealmSwift

class ProductsTableViewController: UITableViewController, ManageItemDelegate {

    let products: Results<Product>
    let realm = DatabaseService.shared.getRealm()
    var notificationToken: NotificationToken?
    var selectedProduct: Product?
    
    required init?(coder aDecoder: NSCoder) {
        
        // initialize products
        products = realm.objects(Product.self).sorted(byKeyPath: "timestamp", ascending: false)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        notificationToken = DatabaseService.shared.addNotificationHandleForRows(objects: products, tableView: self.tableView)
    }
    
    func removeProduct(product: Product) {
        // to remove a product, remove models belong to the product first
        let precidate = NSPredicate(format: "product==%@", product.self)
        DatabaseService.shared.removeObjects(objectType: ProductModel.self, with: precidate)
        DatabaseService.shared.removeObject(object: product)
    }
    
    func openProductForm(sender: Any?) {
        // perform the segue
        performSegue(withIdentifier: Static.segue_openProductForm, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemForm = segue.destination as! ItemEditorController
        // tell destination controller which product is selected
        itemForm.currentProduct = sender == nil ? nil : selectedProduct
        itemForm.clientPage = Static.page_product
    }
    
    // MARK: - ManageItemDelegate
    func addItem(sender: Any?) {
        // set sender as nil to identify if want to create a new item.
        openProductForm(sender: nil)
    }
    
    func editingMode(editing: Bool, animate: Bool) {
        setEditing(editing, animated: animate)
    }
    
    
    // MARK: - TableView Delegate&Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell")
        cell?.textLabel?.text = products[indexPath.row].productName
        cell?.detailTextLabel?.text = products[indexPath.row].productDesc
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // let destination controller know which product is selected
        selectedProduct = products[indexPath.row]
        // let destination controller know it's not a new item
        openProductForm(sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            removeProduct(product: products[indexPath.row])
        case .insert:
            break
        default:
            return
        }
    }
    
}
