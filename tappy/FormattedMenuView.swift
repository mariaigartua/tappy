//
//  FormattedMenuView.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//

import SwiftUI

struct FormattedMenuView: View {
    let menu: Menu
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(menu.name)
                .font(.title)
                .fontWeight(.bold)
            
            ForEach(menu.sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                    
                    ForEach(section.items) { item in
                        MenuItemRow(item: item)
                    }
                }
            }
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(item.price)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
