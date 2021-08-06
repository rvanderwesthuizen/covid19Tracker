//
//  Extentions.swift
//  Covid Tracker
//
//  Created by Ruan van der Westhuizen on 2021/08/05.
//

import Foundation

extension Array {
    public func element (at index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
