//
//  ErrorDisplayInvoker.swift
//  NetworkingEx
//
//  Created by USER on 2022/11/21.
//

import Foundation

protocol ErrorDisplayCommand {
    
    func display()
    
}

final class ErrorDisplayInvoker {
    
    static let shared = ErrorDisplayInvoker()
    
    private init() { }
    
    func perform(command: ErrorDisplayCommand) {
        command.display()
    }
    
}

