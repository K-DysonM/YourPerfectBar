//
//  DrawClearUIView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/16/22.
//

import UIKit
import Cartography

class DrawClearUIView: UIView {
	
	 var clearDrawButton: UIButton = {
		let button = UIButton(type: .close)
		return button
	}()
	
	var clearLabel: UILabel = {
		let label = UILabel()
		label.text = "Drawing Filter"
		label.textAlignment = .left
		label.font = UIFont.boldSystemFont(ofSize: 16)
		label.textColor = DEFAULT_TINT
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
	
	func createSubviews() {
		// UI View setup
		backgroundColor = .systemGroupedBackground.withAlphaComponent(0.9)
		layer.cornerRadius = 13.00
		layer.borderWidth = 0.5
		layer.borderColor = UIColor.darkGray.cgColor

		addSubview(clearDrawButton)
		addSubview(clearLabel)
		constrain(clearDrawButton, clearLabel) { clearDrawButton, clearLabel in
			let superview = clearDrawButton.superview!
			clearDrawButton.top == superview.top + 10
			clearDrawButton.right == superview.right - 10
			clearDrawButton.bottom == superview.bottom - 10
			clearDrawButton.width == 30
			
			clearLabel.top == superview.top
			clearLabel.leading == superview.leading + 10
			clearLabel.bottom == superview.bottom
			clearLabel.trailing == clearDrawButton.leading
		}
	}

}
