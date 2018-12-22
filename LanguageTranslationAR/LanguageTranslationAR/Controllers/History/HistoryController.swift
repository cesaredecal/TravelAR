//
//  HistoryController.swift
//  LanguageTranslationAR
//
//  Created by Cesare de Cal on 07/12/2018.
//  Copyright © 2018 Cesare de Cal. All rights reserved.
//

import UIKit
import FunctionalTableData
import TBEmptyDataSet

class HistoryController: UITableViewController, TranslationItemsDelegate {
    internal let functionalData = FunctionalTableData()
    
    internal var items: [Translation] = [] {
        didSet {
            render()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        items = TranslationItems.shared.array
        setupView()
        setupNavigationBar()
        TranslationItems.shared.delegate = self
        
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        self.navigationItem.searchController = search
    }
        
    private func setupView() {
        view.backgroundColor = .black
        functionalData.tableView = tableView
    
        tableView.emptyDataSetDataSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("History", comment: "History")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    }
    
    @objc func didTapAddButton() {
        let translation = Translation(originalText: "backpackbackpackbackpacddbackpackbackpackbackpacddbackpackbackpackbackpacddbackpackbackpackbackpacddbackpackbackpackbackpacdd", targetLanguage: "es", translatedText: "test1test1test1test1test1test1test1test1test1", sourceLanguage: "en")
        items.append(translation)
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
    
    private func didTapDeleteOnRow(indexPath: IndexPath) {
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        self.items.remove(at: indexPath.row)
    }
    
    private func didSelectCell(translation: Translation) {
        TextToSpeech.speak(item: translation)
        
        // Deselect row
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            
            // Fixes bug in UIKit which causes separator line to hide for a second
            // After deselection
            self.tableView.separatorStyle = .none
            self.tableView.separatorStyle = .singleLine
        }
    }
    
    private func render() {
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: ({ (rowAction, indexPath) in
            self.didTapDeleteOnRow(indexPath: indexPath)
        }))
        
        let cellStyle = CellStyle(bottomSeparator: .inset,
                                  separatorColor: .gray,
                                  highlight: true,
                                  selectionColor: UIColor(named: "selectedCell"),
                                  backgroundColor: .black)
        
        let rows: [CellConfigType] = items.enumerated().map { index, item in
            return HistoryCell(
                key: item.key ?? "",
                style: cellStyle,
                actions: CellActions(
                    selectionAction: { _ in
                        self.didSelectCell(translation: item)
                        return .selected
                },
                    deselectionAction: { _ in
                        return .deselected
                }, rowActions: [deleteRowAction]),
                state: HistoryState(translationItem: item),
                cellUpdater: HistoryState.updateView)
        }
        
        functionalData.renderAndDiff([
            TableSection(key: "section", rows: rows)
            ])
    }
    
    func newItemAdded() {
        items = TranslationItems.shared.array
    }
}

extension HistoryController: TBEmptyDataSetDelegate, TBEmptyDataSetDataSource {
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: "EMPTY_STATE_TITLE".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return attributedString
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: "EMPTY_STATE_DESCRIPTION".localized(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        return attributedString
    }
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "empty-state-view")
    }
    
    func verticalOffsetForEmptyDataSet(in scrollView: UIScrollView) -> CGFloat {
        return -100
    }
}

extension HistoryController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
        
//        let searchText = searchBar.text ?? ""
//        filteredList = items .filter { pokemon in
//            let isMatchingSearchText =    pokemon.name.lowercaseString.containsString(searchText.lowercaseString) || searchText.lowercaseString.characters.count == 0
//            return isMatchingSearchText
//        }
//        render()
//        tableView.reloadData()
    }
}
