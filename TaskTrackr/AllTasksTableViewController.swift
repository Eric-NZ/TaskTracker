//
//  AllTasksTableViewController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 29/08/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit

class AllTasksTableViewController: UITableViewController {
    
    let allTaskArray: [String] = ["task1", "task2", "task3", "task4", "task5", "task6", "task11", "task12", "task13", "task14", "task15", "task16"]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllTaskCell")
        
        cell?.textLabel?.text = allTaskArray[indexPath.row]
        
        return cell!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allTaskArray.count
    }

}
