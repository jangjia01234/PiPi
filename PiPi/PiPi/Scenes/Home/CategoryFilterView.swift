//
//  CategoryFilterView.swift
//  PiPi
//
//  Created by 정상윤 on 7/30/24.
//

import SwiftUI

struct CategoryFilterView: View {
    
    @Binding var selectedCategory: Activity.Category?
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(Activity.Category.allCases, id: \.rawValue) { category in
                categoryButton(category)
                    .frame(maxWidth: .infinity)
                    .background(
                        selectedCategory == category
                        ? Color.accentColor
                        : Color.white
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 100)
                    )
                    .setShadow()
                    .onTapGesture {
                        selectedCategory = (selectedCategory == category) ? nil : category
                    }
            }
        }
        .padding(.vertical)
    }
    
    private func categoryButton(_ category: Activity.Category) -> some View {
        HStack {
            Image(
                selectedCategory == category
                ? "\(category.self).white"
                : "\(category.self).accent"
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 16, height: 16)
            .bold()
            
            Text(category.rawValue)
                .fontWeight(.semibold)
                .foregroundStyle(
                    selectedCategory == category
                    ? Color.white
                    : Color.black
                )
        }
        .frame(height: 30)
        .font(.footnote)
    }
    
}

#Preview {
    CategoryFilterView(selectedCategory: .constant(.sport))
}
