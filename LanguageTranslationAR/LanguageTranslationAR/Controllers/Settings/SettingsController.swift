//
//  SettingsController.swift
//  LanguageTranslationAR
//
//  Created by Cesare de Cal on 12/7/18.
//  Copyright © 2018 Cesare de Cal. All rights reserved.
//

import UIKit
import FunctionalTableData
import MessageUI

class SettingsController: UITableViewController, DidUpdateLanguage {
    
    private let functionalData = FunctionalTableData()
    
    var languages: [Language] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        functionalData.tableView = tableView
        render()
        didUpdateLanguage()
        getLanguages()
        tableView.backgroundColor = .clear
        view.backgroundColor = .black
        tableView.tableFooterView = UIView()
    }
    
    // Primary cell states include the "Translate To" row
    private func getPrimaryCellStates() -> [LabelState] {
        let currentLanguage = LanguagePreferences.getCurrent()
        print("getting current language:", currentLanguage.name)
        let translateCellState = LabelState(text: "SETTINGS_TRANSLATE_TO".localized(), detailText: currentLanguage.name, imageName: "translate", imageBgColor: .red, selector: #selector(didSelectTranslationLanguage))
        return [translateCellState]
    }
    
    private func getSecondaryCellStates() -> [LabelState] {
        let helpCellState = LabelState(text: "SETTINGS_HELP".localized(), imageName: "help", imageBgColor: #colorLiteral(red: 0.2941176471, green: 0.6231607199, blue: 0.9967945218, alpha: 1), selector: #selector(composeSupportEmail))
        let friendCellState = LabelState(text: "SETTINGS_FRIENDS".localized(), imageName: "heart", imageBgColor: #colorLiteral(red: 0.9991746545, green: 0.1697836518, blue: 0.3347602487, alpha: 1), selector: #selector(didSelectShareRow))
        return [helpCellState, friendCellState]
    }
    
    func getLanguages() {
        let languageCode = LanguagePreferences.getLocaleLanguageCode()
        GoogleTranslateAPI.getLanguages(targetLanguage: languageCode) { (languages) in
            self.languages = languages
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc private func didSelectTranslationLanguage() {
        let languagesController = LanguagesTableViewController()
        languagesController.didUpdateLanguageDelegate = self
        languagesController.getTableData(languages: languages)
        navigationController?.pushViewController(languagesController, animated: true)
    }
    
    @objc internal func composeSupportEmail() {
        let composeVC = MFMailComposeViewController()
        composeVC.setToRecipients(["jules_verne@cesare.io"])
        composeVC.mailComposeDelegate = self
        composeVC.setSubject("SUPPORT_MESSAGE_TITLE".localized())
        present(composeVC, animated: true, completion: nil)
    }

    
    @objc private func didSelectShareRow() {
        let text = "SETTINGS_SHARE_TEXT".localized()
        let textShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func deselectRow() {
        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    func didUpdateLanguage() {
        render()
    }
    
    private func render() {
        let primaryCellStyle = CellStyle(bottomSeparator: .inset,
                                         separatorColor: .gray,
                                         highlight: true,
                                         accessoryType: .disclosureIndicator,
                                         selectionColor: #colorLiteral(red: 0.2941176471, green: 0.2980392157, blue: 0.3019607843, alpha: 1),
                                         backgroundColor: .black)
        
        var secondaryCellStyle = primaryCellStyle
        secondaryCellStyle.accessoryType = .none
        
        let primaryRows: [CellConfigType] = getPrimaryCellStates().enumerated().map { index, state in
            return LabelCell(
                key: "id-\(index)",
                style: primaryCellStyle,
                actions: CellActions(
                    selectionAction: { _ in
                        self.deselectRow()
                        self.perform(state.selector, with: nil)
                        return .selected
                },
                    deselectionAction: { _ in
                        return .deselected
                }),
                state: state,
                cellUpdater: LabelState.updateView)
        }
        
        let secondaryRows: [CellConfigType] = getSecondaryCellStates().enumerated().map { index, state in
            return LabelCell(
                key: "id-\(index)",
                style: secondaryCellStyle,
                actions: CellActions(
                    selectionAction: { _ in
                        self.deselectRow()
                        self.perform(state.selector, with: nil)
                        return .selected
                },
                    deselectionAction: { _ in
                        return .deselected
                }),
                state: state,
                cellUpdater: LabelState.updateView)
        }
        
        var headerCellStyle = primaryCellStyle
        headerCellStyle.bottomSeparator = .none
        
        let headerRows: [CellConfigType] = [HeaderCell(key: "key", style: secondaryCellStyle, state: HeaderState(height: 50), cellUpdater: HeaderState.updateView)]
            
//
//                key: "id-3",
//                style: secondaryCellStyle,
//                actions: nil,
//                state: HeaderState(height: 50),
//                cellUpdater: HeaderState.updateView)

        
        
        functionalData.renderAndDiff([TableSection(key: "sectionH", rows: headerRows),
            TableSection(key: "section", rows: primaryRows), TableSection(key: "sectionH2", rows: headerRows), TableSection(key: "section2", rows: secondaryRows)])
    }
}

extension SettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


public typealias HeaderCell = HostCell<SampleHeader, HeaderState, LayoutMarginsTableItemLayout>

public class SampleHeader: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public struct HeaderState: Equatable {
    let height: CGFloat
    
    public init(height: CGFloat) {
        self.height = height
    }
    
    /// Update the view with the contents of the state.
    ///
    /// - Parameters:
    ///   - view: `UIView` that responds to this state.
    ///   - state: data to update the view with. If `nil` the view is being reused by the tableview.
    public static func updateView(_ view: SampleHeader, state: HeaderState?) {
    }
    
    public static func ==(lhs: HeaderState, rhs: HeaderState) -> Bool {
        return false
    }
}
