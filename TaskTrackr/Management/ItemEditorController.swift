//
//  AddItemFormController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 7/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit
import Former
import TagListView

class ItemEditorController: FormViewController {
    
    // client page identifer
    var clientPage: String = ""
    // current item
    var currentService: Service?
    var currentWorker: Worker?
    var currentProduct: Product?
    var currentTool: Tool?
    var currentSite: Site?
    
    // for service
    var serviceTitle: String = ""
    var serviceDesc: String = ""
    var productSelectorMenu: LabelRowFormer<FormLabelCell>?
    var toolSelectorMenu: LabelRowFormer<FormLabelCell>?
    var applicableTools: [Tool] = []
    var applicableModels: [ProductModel] = []
    
    // for product
    var tagListView: TagListView?
    var productName: String = ""
    var productDesc: String = ""
    
    // for worker
    var firstName: String = ""
    var lastName: String = ""
    var role: String = ""
    
    // for tool
    var toolName: String = ""
    var toolDesc: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(donePressed))
        
        // build form
        switch clientPage {
        case Static.page_service:
            buildServiceForm()
        case Static.page_worker:
            buildWorkerForm()
        case Static.page_product:
            buildProductForm()
        case Static.page_tool:
            buildToolForm()
        case Static.page_site:
            buildSiteForm()
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        former.deselect(animated: animated)
    }
    
    @objc func donePressed() {
        var isSaved: Bool = false
        
        switch clientPage {
        case Static.page_service:
            isSaved = saveServiceForm()
        case Static.page_worker:
            isSaved = saveWorkerForm()
        case Static.page_product:
            isSaved = saveProductForm()
        case Static.page_tool:
            isSaved = saveToolForm()
        case Static.page_site:
            isSaved = saveSiteForm()
        default:
            break
        }
        
        // if chose present modally call "dismiss", otherwise, call this:
        if isSaved {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // Section Header
    let createHeader : ((String) -> ViewFormer ) = { text in
        return LabelViewFormer<FormLabelHeaderView>().configure {
            $0.text = text
            $0.viewHeight = 44
        }
    }
    
    // Menu
    let createMenu : ((String, String, (() -> Void)?) -> RowFormer) = { (text, subText, onSelected) in
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.accessoryType = .disclosureIndicator
            }.configure {
                $0.text = text
                $0.subText = subText
            }.onSelected({ _ in
                onSelected?()
            })
    }
    
    // selector
    let createSelectorRow = { (
        text: String,
        subText: String,
        onSelected: ((RowFormer) -> Void)?
        ) -> RowFormer in
        return LabelRowFormer<FormLabelCell>() {
            $0.titleLabel.textColor = .formerColor()
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.subTextLabel.textColor = .formerSubColor()
            $0.subTextLabel.font = .boldSystemFont(ofSize: 14)
            $0.accessoryType = .disclosureIndicator
            }.configure { form in
                _ = onSelected.map { form.onSelected($0) }
                form.text = text
                form.subText = subText
        }
    }
    
    private func sheetSelectorRowSelected(options: [String]) -> (RowFormer) -> Void {
        return { [weak self] rowFormer in
            if let rowFormer = rowFormer as? LabelRowFormer<FormLabelCell> {
                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                options.forEach { title in
                    sheet.addAction(UIAlertAction(title: title, style: .default, handler: { [weak rowFormer] _ in
                        rowFormer?.subText = title
                        // save to variable.
                        self?.role = title
                        rowFormer?.update()
                    })
                    )
                }
                sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self?.present(sheet, animated: true, completion: nil)
                self?.former.deselect(animated: true)
            }
        }
    }
    
    // MARK: - build Service form
    func buildServiceForm(){
        // initialize model list & tool arrays
        if currentService != nil {
            applicableModels = DatabaseService.shared.modelListToArray(from: (currentService?.models)!)
            applicableTools = DatabaseService.shared.toolListToArray(from: (currentService?.tools)!)
        }
        // Service Title
        let nameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Service Title"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "e.g. Install Shower Trays"
                $0.text = currentService != nil ? currentService?.serviceTitle : ""
                serviceTitle = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.serviceTitle = text
        }
        // Service Desc
        let descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Add Service Introduction"
                $0.text = currentService != nil ? currentService?.serviceDesc : ""
                serviceDesc = $0.text!
            }.onTextChanged { (text) in
                // save service desc
                self.serviceDesc = text
        }
        
        let sectionBasic = SectionFormer(rowFormer: nameField, descField).set(headerViewFormer: createHeader("Basic Service Info"))
        
        // MARK: applied products
        productSelectorMenu = createMenu("🚿 Applicable Products", getProductSelectionStateText()) { [weak self] in
            self?.performSegue(withIdentifier: Static.segue_openProductSelector, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        
        // MARK: applied tools
        toolSelectorMenu = createMenu("🔨 Applicable Tools", getToolSelectionStateText()) { [weak self] in
            // perform segue: OpenToolPicker
            self?.performSegue(withIdentifier: Static.segue_openToolSelector, sender: self)
            } as? LabelRowFormer<FormLabelCell>
        
        let sectionSelector = SectionFormer(rowFormer: productSelectorMenu!, toolSelectorMenu!)
        former.append(sectionFormer: sectionBasic, sectionSelector)
    }
    // save Service form
    func saveServiceForm() -> Bool {
        guard !serviceTitle.isEmpty else {
            Static.showToast(toastText: "Please provide an Service Title.")
            return false
        }
        
        var isUpdate = false
        if currentService == nil {       // if it is a new Service
            currentService = Service()
    
        } else {                        // if we are editing an existing Service
            isUpdate = true
        }
        DatabaseService.shared.addService(add: currentService!, serviceTitle, serviceDesc, tools: applicableTools, models: applicableModels, update: isUpdate)
        
        return true
    }
    // MARK: - build Workder form
    func buildWorkerForm() {
        // worker first name
        let firstNameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "First Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "First Name"
                $0.text = currentWorker != nil ? currentWorker?.firstName : ""
                firstName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.firstName = text
        }
        
        // worker last name
        let lastNameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Last Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "Last Name"
                $0.text = currentWorker != nil ? currentWorker?.lastName : ""
                lastName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.lastName = text
        }
        
        let sectionBasic = SectionFormer(rowFormer: firstNameField, lastNameField).set(headerViewFormer: createHeader("Basic Worker Info"))
        
        // worker role
        let options = ["Worker", "Senior Worker", "Lead Worker", "Expert"]
        role = currentWorker == nil ? "" : (currentWorker?.role)!
        let roleRow = createSelectorRow("Role", role, sheetSelectorRowSelected(options: options))
        let sectionRole = SectionFormer(rowFormer: roleRow).set(headerViewFormer: createHeader("Role"))
        former.append(sectionFormer: sectionBasic, sectionRole)
    }
    
    func saveWorkerForm() -> Bool {
        guard !firstName.isEmpty else {
            Static.showToast(toastText: "Please at least provide the first name.")
            return false
        }
        if currentWorker == nil {
            // create a new worker object
            currentWorker = Worker()
            currentWorker?.firstName = firstName
            currentWorker?.lastName = lastName
            currentWorker?.role = role
            
            // add new item
            DatabaseService.shared.addObject(for: currentWorker!)
        } else {
            // update item
            DatabaseService.shared.updateWorker(for: currentWorker!, with: firstName, with: lastName, with: role)
        }
        
        return true
    }
    
    // MARK: - build Product form
    func buildProductForm() {
        
        // initial model array
        let initialModelArray : () -> [ProductModel] = {
            if (self.currentProduct == nil) {
                return []
            } else {
                let models: [ProductModel] = DatabaseService.shared.getModelArray(in: self.currentProduct!)
                return models
            }
        }
        
        // product name
        let nameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Product Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "Product Name"
                $0.text = currentProduct != nil ? currentProduct?.productName : ""
                productName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.productName = text
        }
        // product desc
        let descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Add product introduction."
                $0.text = currentProduct != nil ? currentProduct?.productDesc : ""
                productDesc = $0.text!
            }.onTextChanged { (text) in
                // save product desc
                self.productDesc = text
        }
        
        let sectionBasic = SectionFormer(rowFormer: nameField, descField).set(headerViewFormer: createHeader("Basic Product Info"))
        
        // models
        let tagRow = CustomRowFormer<TagTableViewCell>(instantiateType: .Nib(nibName: "TagTableViewCell")) {
            let models: [String] = initialModelArray().map {
                return $0.modelName!
            }
            $0.modelTagList.addTags(models)
            // save member variable tagListView
            self.tagListView = $0.modelTagList
            }.configure {
                $0.rowHeight = UITableView.automaticDimension
        }
        let tagControl = CustomRowFormer<TagControlTableViewCell>(instantiateType: .Nib(nibName: "TagControlTableViewCell")) {
            $0.onAddPressed = { newTagName in
                // text from the textField in TagControlTableViewCell
                if !newTagName.isEmpty {
                    self.tagListView?.addTag(newTagName)
                    
                    // in order to update the custom cell height
                    self.tableView.reloadData()
                }
            }
        }
        
        let sectionModels = SectionFormer(rowFormer: tagRow, tagControl).set(headerViewFormer: createHeader("Product Models"))
        former.append(sectionFormer: sectionBasic, sectionModels)
    }

    // save Product form
    func saveProductForm() -> Bool {
        guard !productName.isEmpty else {
            Static.showToast(toastText: "Please provide a product name.")
            return false
        }
        
        // changed model array
        let changedModelArray: () -> [ProductModel] = {
            let tagViews: [TagView] = (self.tagListView?.tagViews)!
            let models: [ProductModel] = tagViews.map {
                let model = ProductModel()
                model.modelName = $0.titleLabel?.text
                model.product = self.currentProduct
                return model
            }
            return models
        }
        
        if (currentProduct == nil) {
            // create a new item
            currentProduct = Product()
            currentProduct?.productName = productName
            currentProduct?.productDesc = productDesc
            // add to database
            DatabaseService.shared.addObject(for: currentProduct!)
        } else {
            // edit an existing item
            DatabaseService.shared.updateProduct(for: currentProduct!, with: productName, with: productDesc, with: changedModelArray())
        }
        
        // save models
        DatabaseService.shared.saveModels(to: currentProduct!, with: changedModelArray())
        
        return true
    }
    
    // MARK: - build Tool form
    func buildToolForm() {
        // Tool name
        let nameField = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Tool Name"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textField.textColor = .formerSubColor()
            $0.textField.font = .boldSystemFont(ofSize: 14)
            }.configure {
                $0.placeholder = "Tool Name"
                $0.text = currentTool != nil ? currentTool?.toolName : ""
                toolName = $0.text!
            }.onTextChanged { (text) in
                // save product name
                self.toolName = text
        }
        // Tool desc
        let descField = TextViewRowFormer<FormTextViewCell>() {
            $0.titleLabel.text = "Description"
            $0.titleLabel.font = .boldSystemFont(ofSize: 16)
            $0.textView.textColor = .formerSubColor()
            $0.textView.font = .systemFont(ofSize: 15)
            }.configure {
                $0.placeholder = "Add tool introduction."
                $0.text = currentTool != nil ? currentTool?.toolDesc : ""
                toolDesc = $0.text!
            }.onTextChanged { (text) in
                // save product desc
                self.toolDesc = text
        }
        let sectionBasic = SectionFormer(rowFormer: nameField, descField).set(headerViewFormer: createHeader("Tool Info"))
        
        former.append(sectionFormer: sectionBasic)
    }
    // save Tool form
    func saveToolForm() -> Bool {
        guard !toolName.isEmpty else {
            Static.showToast(toastText: "Please enter a tool name.")
            return false
        }
        
        if currentTool == nil {
            // create a new tool
            currentTool = Tool()
            currentTool?.toolName = toolName
            currentTool?.toolDesc = toolDesc
            // save to database
            DatabaseService.shared.addObject(for: currentTool!)
        } else {
            // update existing tool
            DatabaseService.shared.updateTool(for: currentTool!, with: toolName, with: toolDesc)
        }
        return true
    }
    // build Site form
    func buildSiteForm() {}
    // save Site form
    func saveSiteForm() -> Bool {
        return true
    }
    
}

// MARK: - ToolAndModelPickupDelegate
extension ItemEditorController: ModelPickupDelegate {
    func finishSelection(selectedModels: [ProductModel]) {
        self.applicableModels = selectedModels
        
        // update summary on selector menus
        updateSelectorMenu()
    }
    
    func getProductSelectionStateText() -> String {
        let numberOfModels = applicableModels.count
        
        let productSubText: String = {
            switch numberOfModels {
            case 0:
                return Static.none_selected
            case 1:
                return "1 Model Selected"
            default:
                return String.init(format: "%d Models Selected", numberOfModels)
            }
        }()
        
        return productSubText
    }
    
    func getToolSelectionStateText() -> String {
        let numberOfTools = applicableTools.count
        
        let toolSubText: String = {
            switch numberOfTools {
            case 0:
                return Static.none_selected
            case 1:
                return "1 Tool Selected"
            default:
                return String.init(format: "%d Tools Selected", numberOfTools)
            }
        }()
        
        return toolSubText
    }
    
    func updateSelectorMenu() {
        guard productSelectorMenu != nil else {return}
        guard toolSelectorMenu != nil else {return}
        
        productSelectorMenu?.subText = getProductSelectionStateText()
        toolSelectorMenu?.subText = getToolSelectionStateText()
  
        former.reload()
    }
    
    // MARK: prepare information for the presented selector view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Static.segue_openToolSelector:
            prepareForTool(for: segue)
        case Static.segue_openProductSelector:
            prepareForProduct(for: segue)
        default:
            break
        }
    }
    
    private func prepareForTool(for segue: UIStoryboardSegue) {
        let selector = segue.destination as! ToolPickerViewController
        selector.selectedTools = applicableTools
    }
    
    private func prepareForProduct(for segue: UIStoryboardSegue) {
        let selector = segue.destination as! ProductPickerViewController
        // init original selected models
        
        selector.selectedModels = applicableModels
        
        // init the delegate of selector
        selector.pickupDelegate = self
    }
}
