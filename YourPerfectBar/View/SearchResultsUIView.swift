//
//  SearchResultsUIView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/23/22.
//

import UIKit
import Cartography

class SearchResultsUIView: UIView {

	private var resultsNumber = 0 {
		didSet {
			resultsNumberLabel.text = "\(resultsNumber) Bars"
		}
	}
	
	
	private var resultsNumberLabel: UILabel = {
		let label = UILabel()
		label.text = "0 Bars"
		label.textColor = DEFAULT_TINT
		label.textAlignment = .center
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		createSubviews()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createSubviews()
	}
	func setResultCount(_ number: Int) {
		resultsNumber = number
	}
	
	func createSubviews() {
		// UI View setup
		backgroundColor = .systemGroupedBackground.withAlphaComponent(0.9)
		layer.cornerRadius = 13.00
		layer.borderWidth = 0.5
		layer.borderColor = UIColor.darkGray.cgColor
		
		addSubview(resultsNumberLabel)
		constrain(resultsNumberLabel) { label in
			let superview = label.superview!
			label.centerX == superview.centerX
			label.centerY == superview.centerY
		}
	}
	

}
