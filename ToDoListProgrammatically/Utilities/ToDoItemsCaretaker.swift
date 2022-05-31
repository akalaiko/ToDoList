//
//  ToDoItemsCaretaker.swift
//  ToDoListProgrammatically
//
//  Created by Tim on 31.05.2022.
//

import Foundation

class ToDoItemsCaretaker {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let key = "tasks"
    
    func save(tasks: [ToDoItem]) {
        do {
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print(error)
        }
    }

    func receiveTasks() -> [ToDoItem] {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else { return [] }
        do {
            return try decoder.decode([ToDoItem].self, from: data)
        } catch {
            print(error)
            return []
        }
    }
}
