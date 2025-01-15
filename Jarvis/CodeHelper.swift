//
//  CodeHelper.swift
//  Jarvis
//
//  Created by Gabriel Winkler on 1/14/25.
//


import Foundation

class CodeHelper {
    func checkSyntax(for code: String) -> String {
        // Ein einfaches Beispiel für die Überprüfung der Syntax eines Swift-Codes
        let keywords = ["func", "let", "var", "return"]
        var errors = [String]()
        
        for keyword in keywords {
            if !code.contains(keyword) {
                errors.append("Missing keyword: \(keyword)")
            }
        }
        
        return errors.isEmpty ? "Code is valid!" : errors.joined(separator: "\n")
    }
}
