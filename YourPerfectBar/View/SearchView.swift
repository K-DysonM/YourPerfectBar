//
//  SearchView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/11/22.
//

import UIKit

class SearchView: UIViewController, UISearchBarDelegate {
	var searchBar: UISearchBar!
	var backgroundView: UIView!
	var searchBarReceiver: SearchBarReceiverProtocol?
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .clear
		createSubviews()
	}
	override func viewDidLoad() {
		searchBar.delegate = self
		assert(searchBarReceiver != nil, "Invalid Setup SearchView missing SearchBarReceiverProtocol")
		
	}
	override func viewDidLayoutSubviews() {
		UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.35, options: []) {
			self.searchBar.transform = CGAffineTransform(translationX: 0.0, y: 90.00)
		}
		searchBar.becomeFirstResponder()
	}

	func createSubviews() {
		backgroundView = UIView()
		backgroundView.backgroundColor = .lightGray.withAlphaComponent(0.4)
		backgroundView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(backgroundView)
		
		searchBar = UISearchBar(frame: .zero)
		view.addSubview(searchBar)
		searchBar.placeholder = "Search"
		searchBar.showsCancelButton = true
		searchBar.backgroundImage = UIImage()
		searchBar.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
		searchBar.layer.borderColor = UIColor.white.cgColor
		searchBar.tintColor = UIColor(named: "HunterGreen")
		searchBar.enablesReturnKeyAutomatically = true
		searchBar.returnKeyType = .search
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate(
			[searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: -70),
			 searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
			 searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
			 searchBar.heightAnchor.constraint(equalToConstant: 50.00),
			 backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			 backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
			 backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
			 backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			]
		)
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.endEditing(true)
		dismiss(animated: false)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchBarReceiver = searchBarReceiver, let text = searchBar.searchTextField.text {
			searchBarReceiver.sendSearchBarText(text)
		}
	}
	
}
