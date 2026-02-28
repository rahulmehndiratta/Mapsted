//
//  DropdownRowView.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import SwiftUI

/// A row with a title, optional dropdown for selection, and a value on the right.
struct DropdownRowView<Value: Hashable>: View {
    let title: String
    let placeholder: String
    let options: [Value]
    let optionLabel: (Value) -> String
    let selection: Value?
    let onSelect: (Value) -> Void
    let valueText: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textLightGrey)
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(optionLabel(option)) {
                            onSelect(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.map(optionLabel) ?? placeholder)
                            .foregroundColor(AppTheme.textDarkGrey)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(AppTheme.textLightGrey)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.darkGrey)
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(valueText)
                .font(.headline)
                .foregroundColor(AppTheme.textDarkGrey)
                .multilineTextAlignment(.trailing)
                .frame(minWidth: 80, alignment: .trailing)
        }
        .padding()
        .background(AppTheme.lightGrey)
        .cornerRadius(10)
    }
}
