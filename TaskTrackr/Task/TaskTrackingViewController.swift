//
//  ActivatedTableViewController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 29/08/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit
import RealmSwift

class TaskTrackingViewController: UIViewController {
    
    @IBOutlet weak var tableView: TimelineTableView!
    var taskNotification: NotificationToken?
    var tasks: Results<Task>
    
    required init?(coder aDecoder: NSCoder) {
        tasks = DatabaseService.shared.getAllTasks()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskNotification = DatabaseService.shared.addNotificationHandleForSections(objects: tasks, tableView: self.tableView, callback: nil)
        
        // init callbacks
        setupTableViewDataSource()
    }
    
    deinit {
        taskNotification?.invalidate()
    }

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: Static.segue_openTaskEditor, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editor = segue.destination as! TaskEditorViewController
        // if nil, means it should be a new task
        editor.currentTask = sender as? Task
    }
}

// MARK: - Implement callbacks
extension TaskTrackingViewController {
    func setupTableViewDataSource() {
        
        tableView.numberOfSections {
            return self.tasks.count
        }
        
        tableView.dataForHeader { (section) -> SectionData in
            return self.dataForHeaderInSection(in: section) ?? SectionData()
        }
        
        tableView.numberOfRowsInSection {
            return self.tasks[$0].stateLogs.count
        }
        
        tableView.dataForRowAtIndexPath {
            return self.cellDataForRowAtIndexPath(indexPath: $0) ?? CellData()
        }
    }
    
    private func dataForHeaderInSection(in section: Int) -> SectionData? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        let task = self.tasks[section]
        var headerData = SectionData()
        // title
        headerData.title = task.taskTitle
        // desc
        let postInfo = String(format: "Created by %@, on %@", "Manager", formatter.string(from: task.timestamp))
        headerData.subTitle = postInfo
        // address
        headerData.bulletSecond = task.address
        // due date
        let dueDateString = formatter.string(from: task.dueDate)
        headerData.bulletThird = String(format: "Deadline: %@", dueDateString)
        
        headerData.bulletFirst = buildWorkerAttributedText(workers: task.workers)
        // image
        if task.images.count > 0 {
            headerData.image = UIImage(data: task.images[0])!
        }
        
        return headerData
    }
    
    private func buildWorkerAttributedText(workers: List<Worker>) -> NSAttributedString {
        let attributedText: NSMutableAttributedString = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "Worker: ", attributes: [:]))
        
        // if there are no workers
        if workers.count == 0 {
            let warning = "No worker designated. "
            attributedText.append(NSAttributedString(string: warning, attributes: [.foregroundColor: UIColor.red]))
        } else {
            var workerString = ""
            for worker in workers {
                workerString.append(contentsOf: worker.firstName!)
                workerString.append(contentsOf: "; ")
            }
            // remove last "; "
            workerString.removeLast(2)
            attributedText.append(NSAttributedString(string: workerString, attributes: [.font : UIFont.boldSystemFont(ofSize: 12)]))
        }
        
        
        return attributedText
    }
    
    // MARK: - setup cell data
    private func cellDataForRowAtIndexPath(indexPath: IndexPath) -> CellData? {
        let task = self.tasks[indexPath.section]
        let stateLog = task.stateLogs[indexPath.row]
        var cellData = CellData()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        // the buttons are only available where it is the last row
        let isFinalCell: Bool = indexPath.row == task.stateLogs.count - 1
        cellData.illustrateTitleBold = isFinalCell ? true : false
        
        switch stateLog.taskState {
        case .created:
            cellData.timeText = formatter.string(from: stateLog.timestamp)
            cellData.illustrateTitle = "Created"
            cellData.illustrateImage = UIImage(named: "created")
            cellData.isFirstCell = true
            cellData.buttonAttributes = isFinalCell ? [CellData.ButtonAttributeTuple(0, self, UIImage(named: "next"), {()->Void in
                // callback closure
                let state: TaskLog.TaskState = .pending
                self.changeTaskState(for: task, nextState: state)
            }), CellData.ButtonAttributeTuple(1, self, UIImage(named: "edit"), { [weak self] in
                // callback closure
                self?.performSegue(withIdentifier: Static.segue_openTaskEditor, sender: task)
                
            }), CellData.ButtonAttributeTuple(2, self, UIImage(named: "trash"), {()->Void in
                // callback closure
                self.removeTask(task: task)
            }), CellData.ButtonAttributeTuple(3, self, UIImage(named: "info"), {()->Void in
                // callback closure
                
            })] : []
        case .pending:
            cellData.timeText = formatter.string(from: stateLog.timestamp)
            cellData.illustrateTitle = "Pending"
            cellData.illustrateImage = UIImage(named: "pending")
            cellData.buttonAttributes = isFinalCell ? [CellData.ButtonAttributeTuple(0, self, UIImage(named: "comment"), {()->Void in
                // callback closure
                
            }), CellData.ButtonAttributeTuple(1, self, UIImage(named: "info"), {()->Void in
                // callback closure
                self.infoTapped()
            }), CellData.ButtonAttributeTuple(2, self, UIImage(named: "cancel"), {()->Void in
                // callback closure: back to previous state with offset - 1
                self.backToPreviousState(for: task, offset: 1)
            })] : []
        case .processing:
            cellData.timeText = formatter.string(from: stateLog.timestamp)
            cellData.illustrateTitle = "Processing"
            cellData.illustrateImage = UIImage(named: "processing")
            cellData.buttonAttributes = isFinalCell ? [CellData.ButtonAttributeTuple(0, self, UIImage(named: "comment"), {()->Void in
                // callback closure
                
            }), CellData.ButtonAttributeTuple(1, self, UIImage(named: "info"), {()->Void in
                // callback closure
                
            }), CellData.ButtonAttributeTuple(2, self, UIImage(named: "fail"), {()->Void in
                // callback closure
                self.changeTaskState(for: task, nextState: .failed)
            })] : []
        case .finished:
            cellData.timeText = formatter.string(from: stateLog.timestamp)
            cellData.illustrateTitle = "Finished"
            cellData.illustrateTitleColor = UIColor.blue
            cellData.illustrateImage = UIImage(named: "finished")
            cellData.isFinalCell = true
            cellData.buttonAttributes = isFinalCell ? [CellData.ButtonAttributeTuple(0, self, UIImage(named: "approve"), {()->Void in
                // callback closure
                
            }), CellData.ButtonAttributeTuple(1, self, UIImage(named: "backward"), {()->Void in
                // callback closure
                self.backToPreviousState(for: task, offset: 2)
            }), CellData.ButtonAttributeTuple(2, self, UIImage(named: "info"), {()->Void in
                // callback closure
                
            })] : []
        case .failed:
            cellData.timeText = formatter.string(from: stateLog.timestamp)
            cellData.illustrateTitle = "Failed"
            cellData.illustrateTitleColor = UIColor.red
            cellData.illustrateImage = UIImage(named: "failed")
            cellData.isFinalCell = true
            cellData.buttonAttributes = isFinalCell ? [CellData.ButtonAttributeTuple(0, self, UIImage(named: "archive"), {()->Void in
                // callback closure
                
            }), CellData.ButtonAttributeTuple(1, self, UIImage(named: "trash"), {()->Void in
                // callback closure
                self.removeTask(task: task)
            }), CellData.ButtonAttributeTuple(2, self, UIImage(named: "info"), {()->Void in
                // callback closure
                
            })] : []
        }
        
        return cellData
    }
    
    private func removeTask(task: Task) {
        DatabaseService.shared.removeObject(object: task)
    }
    
    private func changeTaskState(for task: Task, nextState: TaskLog.TaskState) {
        DatabaseService.shared.addTaskStateLog(for: task, to: nextState)
    }
    
    private func backToPreviousState(for task: Task, offset: Int) {
        DatabaseService.shared.backToPreviousState(for: task, offset: offset)
    }
    
    func infoTapped() {
        
    }
}
