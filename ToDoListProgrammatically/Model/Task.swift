//
//  Task.swift
//  ToDoListProgrammatically
//
//  Created by Tim on 31.05.2022.
//

import Foundation

protocol Task: Codable {
    var name: String { get }
}

class ToDoItem: Task {
    
    var name: String
    var subTasks: [ToDoItem] = []
    
    init (name: String) {
        self.name = name
    }

    enum CodingKeys: CodingKey {
        case name
        case subTasks
    }
    
    required init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           subTasks = try container.decode ([ToDoItem].self, forKey: .subTasks)
           name = try container.decode (String.self, forKey: .name)
      }

    func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       try container.encode (subTasks, forKey: .subTasks)
       try container.encode (name, forKey: .name)
    }
}

extension ToDoItem: Equatable {
    static func == (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
        return lhs.name == rhs.name
    }
}
