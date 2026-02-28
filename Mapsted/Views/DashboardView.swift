//
//  DashboardView.swift
//  SwiftUITest
//
//  Main dashboard UI: dropdown rows and computed values per test case spec.
//
import SwiftUI

struct DashboardView: View {
    
    @StateObject private var viewModel = DashboardViewModel()
    @State private var activeSelector: SelectorType?

    private enum SelectorType: String, Identifiable {
        case manufacturer
        case category
        case country
        case state
        case item

        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationView {
            content
                .listStyle(.plain)
                .navigationTitle(AppStrings.General.appTitle)
        }
        .sheet(item: $activeSelector) { selector in
            selectionSheet(for: selector)
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Main list content
    
    private var content: some View {
        List {
            // Header info
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppStrings.Header.testCaseTitle)
                        .font(.headline)
                        .foregroundColor(AppTheme.textDarkGrey)
                    Text(AppStrings.Header.authorName)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textDarkGrey)
                    Text(AppStrings.Header.date)
                        .font(.caption)
                        .foregroundColor(AppTheme.textLightGrey)
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.clear)

            if viewModel.isOffline || viewModel.loadError != nil {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.loadError ?? AppStrings.General.somethingWentWrong)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button(AppStrings.General.retry) {
                            Task {
                                await viewModel.loadData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }
            } else if viewModel.isLoading {
                Section {
                    ZStack {
                        Color(.systemBackground)
                            .opacity(0.65)
                            .ignoresSafeArea()

                        VStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(AppTheme.textDarkGrey)
                                .scaleEffect(1.05)

                            Text(AppStrings.General.loading)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textDarkGrey)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppTheme.lightGrey.opacity(0.92))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppTheme.darkGrey.opacity(0.7), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
                    }
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.75)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            
            // Purchase costs: Manufacturer, Category, Country, State (single section)
            Section(
                header:
                    ZStack {
                        AppTheme.lightBlue
                        HStack {
                            Text(AppStrings.Sections.purchaseCosts)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textDarkGrey)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: AppConstants.Layout.sectionHeaderHeight)
                    .padding(.horizontal, -AppConstants.Layout.listSectionHorizontalInset)
            ) {
                // Manufacturer
                ZStack {
                    AppTheme.lightGrey
                    HStack(alignment: .center, spacing: 0) {
                        Text(AppStrings.Fields.manufacturer + ":")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textLightGrey)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        Spacer(minLength: AppConstants.Layout.rowLabelToButtonSpacing)
                        Button {
                            activeSelector = .manufacturer
                        } label: {
                            HStack {
                                Spacer(minLength: 2)
                                Text(manufacturerLabel())
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textDarkGrey)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textLightGrey)
                                    .padding(.trailing, 4)
                            }
                            .padding(.vertical, 8)
                            .frame(width: AppConstants.Layout.selectionButtonWidth)
                            .background(AppTheme.darkGrey)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: AppConstants.Layout.rowButtonToValueSpacing)
                        Text(formatCurrency(viewModel.manufacturerTotal))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textDarkGrey)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 4)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

                // Category
                ZStack {
                    AppTheme.lightGrey
                    HStack(alignment: .center, spacing: 0) {
                        Text(AppStrings.Fields.category + ":")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textLightGrey)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        Spacer(minLength: AppConstants.Layout.rowLabelToButtonSpacing)
                        Button {
                            activeSelector = .category
                        } label: {
                            HStack {
                                Spacer(minLength: 2)
                                Text(categoryLabel())
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textDarkGrey)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textLightGrey)
                                    .padding(.trailing, 4)
                            }
                            .padding(.vertical, 8)
                            .frame(width: AppConstants.Layout.selectionButtonWidth)
                            .background(AppTheme.darkGrey)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: AppConstants.Layout.rowButtonToValueSpacing)
                        Text(formatCurrency(viewModel.categoryTotal))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textDarkGrey)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 4)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

                // Country
                ZStack {
                    AppTheme.lightGrey
                    HStack(alignment: .center, spacing: 0) {
                        Text(AppStrings.Fields.country + ":")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textLightGrey)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        Spacer(minLength: AppConstants.Layout.rowLabelToButtonSpacing)
                        Button {
                            activeSelector = .country
                        } label: {
                            HStack {
                                Spacer(minLength: 2)
                                Text(countryLabel())
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textDarkGrey)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textLightGrey)
                                    .padding(.trailing, 4)
                            }
                            .padding(.vertical, 8)
                            .frame(width: AppConstants.Layout.selectionButtonWidth)
                            .background(AppTheme.darkGrey)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: AppConstants.Layout.rowButtonToValueSpacing)
                        Text(formatCurrency(viewModel.countryTotal))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textDarkGrey)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 4)
                }
                
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))

                // State
                ZStack {
                    AppTheme.lightGrey
                    HStack(alignment: .center, spacing: 0) {
                        Text(AppStrings.Fields.stateProvince + ":")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textLightGrey)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        Spacer(minLength: AppConstants.Layout.rowLabelToButtonSpacing)
                        Button {
                            activeSelector = .state
                        } label: {
                            HStack {
                                Spacer(minLength: 2)
                                Text(stateLabel())
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textDarkGrey)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textLightGrey)
                                    .padding(.trailing, 4)
                            }
                            .padding(.vertical, 8)
                            .frame(width: AppConstants.Layout.selectionButtonWidth)
                            .background(AppTheme.darkGrey)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: AppConstants.Layout.rowButtonToValueSpacing)
                        Text(formatCurrency(viewModel.stateTotal))
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textDarkGrey)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 4)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            .listRowBackground(Color.clear)
            
            // Number of purchases section
            Section(
                header:
                    ZStack {
                        AppTheme.lightBlue
                        HStack {
                            Text(AppStrings.Sections.numberOfPurchases)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textDarkGrey)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: AppConstants.Layout.sectionHeaderHeight)
                    .padding(.horizontal, -AppConstants.Layout.listSectionHorizontalInset)
            ) {
                ZStack {
                    AppTheme.lightGrey
                    HStack(alignment: .center, spacing: 0) {
                        Text(AppStrings.Fields.item + ":")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textLightGrey)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        Spacer(minLength: AppConstants.Layout.rowLabelToButtonSpacing)
                        Button {
                            activeSelector = .item
                        } label: {
                            HStack {
                                Spacer(minLength: 2)
                                Text(itemLabel())
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textDarkGrey)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppTheme.textLightGrey)
                                    .padding(.trailing, 4)
                            }
                            .padding(.vertical, 8)
                            .frame(width: AppConstants.Layout.selectionButtonWidth)
                            .background(AppTheme.darkGrey)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: AppConstants.Layout.rowButtonToValueSpacing)
                        Text("\(viewModel.itemPurchaseCount)")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textDarkGrey)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 4)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            }
            .listRowBackground(Color.clear)
            
            // Most total purchases section
            Section(
                header:
                    ZStack {
                        AppTheme.lightBlue
                        HStack {
                            Text(AppStrings.Sections.mostTotalPurchases)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(AppTheme.textDarkGrey)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    .frame(height: AppConstants.Layout.sectionHeaderHeight)
                    .padding(.horizontal, -AppConstants.Layout.listSectionHorizontalInset)
            ) {
                ZStack {
                    AppTheme.lightGrey
                    HStack(alignment: .center, spacing: 0) {
                        Text(AppStrings.Fields.building + ":")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textLightGrey)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.leading, 4)
                        Spacer(minLength: AppConstants.Layout.rowLabelToButtonSpacing)
                        Text(viewModel.buildingWithMostTotalPurchasesName)
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textDarkGrey)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                .padding(.horizontal, 4)
            }
            .listRowBackground(Color.clear)
        }
    }

    // MARK: - Formatting helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppConstants.Formatting.currencyCode
        formatter.maximumFractionDigits = AppConstants.Formatting.maxFractionDigits
        formatter.minimumFractionDigits = AppConstants.Formatting.minFractionDigits
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func manufacturerLabel() -> String {
        if let value = viewModel.selectedManufacturer {
            return value
        }
        if let first = viewModel.manufacturerOptions.first {
            return first
        }
        return AppStrings.Placeholders.selectManufacturer
    }

    private func categoryLabel() -> String {
        if let id = viewModel.selectedCategoryId {
            return "Category \(id)"
        }
        if let first = viewModel.categoryOptions.first {
            return "Category \(first)"
        }
        return AppStrings.Placeholders.selectCategory
    }

    private func countryLabel() -> String {
        if let value = viewModel.selectedCountry {
            return value
        }
        if let first = viewModel.countryOptions.first {
            return first
        }
        return AppStrings.Placeholders.selectCountry
    }

    private func stateLabel() -> String {
        if let value = viewModel.selectedState {
            return value
        }
        if let first = viewModel.stateOptions.first {
            return first
        }
        return AppStrings.Placeholders.selectState
    }

    private func itemLabel() -> String {
        if let id = viewModel.selectedItemId {
            return "Item \(id)"
        }
        if let first = viewModel.itemOptions.first {
            return "Item \(first)"
        }
        return AppStrings.Placeholders.selectItem
    }

    // MARK: - Selection sheets

    private func selectionSheet(for selector: SelectorType) -> AnyView {
        switch selector {
        case .manufacturer:
            return AnyView(
            SelectionSheetView(
                title: AppStrings.Sheets.selectManufacturerTitle,
                    options: viewModel.manufacturerOptions,
                    optionLabel: { $0 },
                    onSelect: { value in
                        viewModel.selectedManufacturer = value
                    }
                )
            )
        case .category:
            return AnyView(
            SelectionSheetView(
                title: AppStrings.Sheets.selectCategoryTitle,
                    options: viewModel.categoryOptions,
                    optionLabel: { "Category \($0)" },
                    onSelect: { value in
                        viewModel.selectedCategoryId = value
                    }
                )
            )
        case .country:
            return AnyView(
            SelectionSheetView(
                title: AppStrings.Sheets.selectCountryTitle,
                    options: viewModel.countryOptions,
                    optionLabel: { $0 },
                    onSelect: { value in
                        viewModel.selectedCountry = value
                    }
                )
            )
        case .state:
            return AnyView(
            SelectionSheetView(
                title: AppStrings.Sheets.selectStateTitle,
                    options: viewModel.stateOptions,
                    optionLabel: { $0 },
                    onSelect: { value in
                        viewModel.selectedState = value
                    }
                )
            )
        case .item:
            return AnyView(
            SelectionSheetView(
                title: AppStrings.Sheets.selectItemTitle,
                    options: viewModel.itemOptions,
                    optionLabel: { "Item \($0)" },
                    onSelect: { value in
                        viewModel.selectedItemId = value
                    }
                )
            )
        }
    }
}
#Preview {
    DashboardView()
}
