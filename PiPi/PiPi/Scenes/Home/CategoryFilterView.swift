//
//  CategoryFilterView.swift
//  PiPi
//
//  Created by 정상윤 on 7/30/24.
//

import SwiftUI

struct CategoryFilterView: View {
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(Activity.Category.allCases, id: \.rawValue) { category in
                categoryButton(category)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 100)
                    )
                    .setShadow()
            }
        }
        .padding(.vertical)
    }
    
    private func categoryButton(_ category: Activity.Category) -> some View {
        HStack {
            Image("\(category.self).accent")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(.accent)
                .bold()
            
            Text(category.rawValue)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
        }
        .frame(height: 30)
        .font(.footnote)
    }
    
}

#Preview {
    CategoryFilterView()
}
