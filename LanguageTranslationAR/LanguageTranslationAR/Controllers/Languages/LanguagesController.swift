//
//  LanguagesController.swift
//  LanguageTranslationAR
//
//  Created by Cesare de Cal on 6/8/18.
//  Copyright © 2018 Cesare de Cal. All rights reserved.
//

import UIKit

class LanguagesController: UIViewController {
    
    var tableViewSource = [Character: [Language]]()
    var tableViewHeaders = [Character]()
    var filteredTableViewSource = [Character: [Language]]()
    var filteredTableViewHeaders = [Character]()
    
    var didUpdateLanguageDelegate: DidUpdateLanguage?
    
    var selectedIndexPath: IndexPath?
    
    var selectedLanguage: Language? {
        didSet {
            guard let language = selectedLanguage else { return }
            let buttonTitle = "SAVE_LANGUAGE_NAME".localizedString(with: [language.name])
            chooseButton.setTitle(buttonTitle, for: .normal)
            LanguagePreferences.save(language: language)
            print("Saving language \(language.name), code: \(language.code)")
        }
    }
    
    var isFiltering = false
    let cellId = "reuseIdentifier"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let chooseButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.setTitle("SAVE".localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.isNavigationBarHidden = false
        getLanguages()
    }
    
    func getLanguages() {
        let languageCode = LanguagePreferences.getLocaleLanguageCode()
        GoogleTranslateAPI.getAvailableLanguages(targetLanguage: languageCode) { (languages) in
            (self.tableViewHeaders, self.tableViewSource) = self.createTableData(languagesList: languages)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
        
    private func setupSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.delegate = self
        search.dimsBackgroundDuringPresentation = false
        search.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        title = "SETTINGS_TRANSLATE_TO".localized
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSaveBarButtonItem))
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .black
        tableView.reloadData()
        
        view.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        view.addSubview(chooseButton)
        chooseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        chooseButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        chooseButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        chooseButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    @objc private func dismissViewController() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func didTapSaveBarButtonItem() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        dismissViewController()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
