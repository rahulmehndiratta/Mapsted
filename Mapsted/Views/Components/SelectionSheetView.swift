//
//  SelectionSheetView.swift
//  Mapsted
//
//  Created by RahulM on 28/02/26.
//

import SwiftUI

struct SelectionSheetView<Value: Hashable>: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let options: [Value]
    let optionLabel: (Value) -> String
    let onSelect: (Value) -> Void

    @State private var searchText: String = ""

    private var filteredOptions: [Value] {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return options }
        return options.filter { optionLabel($0).localizedCaseInsensitiveContains(text) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredOptions, id: \.self) { option in
                    Button {
                        onSelect(option)
                        dismiss()
                    } label: {
                        HStack {
                            Text(optionLabel(option))
                            Spacer()
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppStrings.General.close) {
                        dismiss()
                    }
                }
            }
        }
    }
}

