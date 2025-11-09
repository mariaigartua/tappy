//
//  MenuModel.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//

import Foundation

struct Menu: Codable, Identifiable {
    let id: UUID
    let name: String
    let sections: [MenuSection]
    let firebaseId: String?
    
    init(name: String = "Menu", sections: [MenuSection] = [], firebaseId: String? = nil) {
        self.id = UUID()
        self.name = name
        self.sections = sections
        self.firebaseId = firebaseId
    }
}

struct MenuSection: Codable, Identifiable {
    let id: UUID
    let name: String
    var items: [MenuItem]
    
    init(name: String, items: [MenuItem] = []) {
        self.id = UUID()
        self.name = name
        self.items = items
    }
}

struct MenuItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let price: String
    let description: String?
    
    init(name: String, price: String, description: String? = nil) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.description = description
    }
}
