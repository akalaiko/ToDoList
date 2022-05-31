//
//  ViewController.swift
//  ToDoListProgrammatically
//
//  Created by Tim on 31.05.2022.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let tableView = UITableView()
    private var safeArea: UILayoutGuide!
    private var alertController = UIAlertController()
    private var toDoItemsCaretaker = ToDoItemsCaretaker()
    
    // MARK: - Properties
    
    var isRootController: Bool = true
    var parentController: ViewController? {
        didSet {
            guard let parentController = parentController, !parentController.isRootController else { return }
            if let currentItem = parentController.currentItem  {
                currentItem.subTasks = parentController.toDoList
                if let index = parentController.parentController?.toDoList.firstIndex(of: currentItem) {
                    parentController.parentController?.toDoList[index] = currentItem
                }
            }
        }
    }
    var currentItem: ToDoItem?
    var toDoList: [ToDoItem] = [] {
        didSet {
            tableView.reloadData()
            if let currentItem = currentItem {
                currentItem.subTasks = toDoList
                if let index = parentController?.toDoList.firstIndex(of: currentItem) {
                    parentController?.toDoList[index] = currentItem
                }
            }
            guard isRootController else {
                guard let parentController = parentController, parentController.isRootController else { return }
                Session.shared.update(tasks: parentController.toDoList)
                return
            }
            Session.shared.update(tasks: toDoList)
        }
    }
    
    // MARK: - Init

    init(toDoList: [ToDoItem]) {
        self.toDoList = toDoList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - Private Functions
    
    @objc private func setupAlertController() {
        let alert = UIAlertController(title: "Enter task title:", message: nil, preferredStyle: .alert)
        let enterNameAction = UIAlertAction(title: "Save", style: .default, handler: setName)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField { textField in textField.placeholder = "Task Name" }
        alert.addAction(enterNameAction)
        alert.addAction(cancelAction)
        alertController = alert
        present(alertController, animated: true)
    }
    
    @objc private func deleteAllTasks() {
        toDoList.removeAll()
    }
    
    private func setName(action: UIAlertAction! = nil) {
        if let textField = alertController.textFields?.first {
            if let text = textField.text {
                let taskName = (text != "") ? text : textField.placeholder ?? "Empty"
                toDoList.append(ToDoItem(name: taskName))
            }
        }
    }

    private func initialSetup() {
        safeArea = view.layoutMarginsGuide
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(setupAlertController)),
                                                   UIBarButtonItem(image: UIImage(systemName: "trash"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(deleteAllTasks))]
        
        guard isRootController else { return }
        toDoList = toDoItemsCaretaker.receiveTasks()
        title = "ToDoList"
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return toDoList.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = toDoList[indexPath.row]
        cell.textLabel?.text = "\(task.name.capitalized)"
        let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
        label.text = "subtasks: \(task.subTasks.count)"
        cell.accessoryView = label
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = toDoList[indexPath.row]
        let newVC = ViewController(toDoList: selectedTask.subTasks)
        newVC.title = selectedTask.name.capitalized
        newVC.currentItem = selectedTask
        newVC.isRootController = false
        newVC.parentController = self
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDoList.remove(at: indexPath.row)
        }
    }
}
