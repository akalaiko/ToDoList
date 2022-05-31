//
//  Session.swift
//  ToDoListProgrammatically
//
//  Created by Tim on 31.05.2022.
//

import Foundation

class Session {
    
    // MARK: - Singleton init
    
    static let shared = Session()
    private init() {}
    
    // MARK: - Private Properties
    
    private let toDoItemsCaretaker = ToDoItemsCaretaker()
    private var tasks = [ToDoItem]() {
        didSet {
            toDoItemsCaretaker.save(tasks: tasks)
        }
    }
    
    // MARK: - Functions
    
    func update(tasks: [ToDoItem]) {
        self.tasks = tasks
    }

}


