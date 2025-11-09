//
//  MenuDisplayView.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//

// MenuDisplayView.swift
import SwiftUI

struct MenuDisplayView: View {
    let menu: Menu
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(menu.sections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .accessibilityAddTraits(.isHeader)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(section.items) { item in
                                MenuItemRow(item: item)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(menu.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
