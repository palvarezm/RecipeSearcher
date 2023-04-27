//
//  String+Extension.swift
//  RecipeSearcher
//
//  Created by Paul Alvarez on 27/04/23.
//

import Foundation

extension String {
    // MARK: - Language string assets
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }
    
    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, args)
    }
}
