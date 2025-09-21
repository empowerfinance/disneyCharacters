//
//  CategoryDetailView.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import SwiftUI

struct CategoryDetailView: View {
    let categoryTitle: String
    let items: [String]
    let characterName: String
    
    var body: some View {
        NavigationView {
            List {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No \(categoryTitle)",
                        systemImage: "list.bullet",
                        description: Text("\(characterName) doesn't appear in any \(categoryTitle.lowercased()).")
                    )
                } else {
                    ForEach(items, id: \.self) { item in
                        CategoryItemRow(item: item)
                    }
                }
            }
            .navigationTitle(categoryTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CategoryItemRow: View {
    let item: String
    
    var body: some View {
        HStack {
            Image(systemName: iconForItem())
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap for more details")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            // Future: Could navigate to detailed item view
            print("Tapped on: \(item)")
        }
    }
    
    private func iconForItem() -> String {
        // Simple icon selection based on common keywords
        let lowercased = item.lowercased()
        
        if lowercased.contains("kingdom") || lowercased.contains("hearts") {
            return "gamecontroller"
        } else if lowercased.contains("tv") || lowercased.contains("show") {
            return "tv"
        } else if lowercased.contains("film") || lowercased.contains("movie") {
            return "film"
        } else if lowercased.contains("park") || lowercased.contains("attraction") {
            return "location"
        } else if lowercased.contains("ally") || lowercased.contains("friend") {
            return "person.2"
        } else if lowercased.contains("enemy") || lowercased.contains("villain") {
            return "person.badge.minus"
        } else {
            return "star"
        }
    }
}

// MARK: - Preview

#Preview {
    CategoryDetailView(
        categoryTitle: "Films",
        items: [
            "The Lion King",
            "The Lion King II: Simba's Pride",
            "The Lion King 1½",
            "The Lion Guard: Return of the Roar"
        ],
        characterName: "Simba"
    )
}

#Preview("Empty State") {
    CategoryDetailView(
        categoryTitle: "Video Games",
        items: [],
        characterName: "Test Character"
    )
}
