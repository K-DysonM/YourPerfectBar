//
//  BarsCollectionView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/3/22.
//

import UIKit

class BarsCollectionView: UICollectionView {
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		createSubviews()
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createSubviews()
	}
	
	func createSubviews() {
		// Collection View setup
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .clear
		register(UINib(nibName: "BarCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Bar")
		showsHorizontalScrollIndicator = false
	}
	
	func show() {
		UIView.animate(withDuration: 0.65, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
			self.transform = .identity
		}
	}
	
	func hide() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: []) {
			self.transform = CGAffineTransform(translationX: 0.0, y: +400)
		}
	}
	
	func animateToItem(at index: IndexPath) {
		// This is where we will implement the cell growing larger if its being shown
		#warning("Bug where if animated is true it doesn't scrollToItem")
		scrollToItem(at: index, at: .centeredHorizontally, animated: false)
	}

}
