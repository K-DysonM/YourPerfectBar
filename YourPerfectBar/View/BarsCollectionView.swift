//
//  BarsCollectionView.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/3/22.
//

import UIKit

class BarsCollectionView: UICollectionView {
	var currentIndex: IndexPath?
	
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
		contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
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
		
		guard let dataSource = dataSource else { return }
		
		// Shrink the previous cell
		if let currentIndex = currentIndex {
			let cell = cellForItem(at: currentIndex) as? BarCollectionViewCell
			cell?.transformToOriginal()
		}
		currentIndex = index
		
		// If cell is already a visible cell then just enlarge it
		if let cell = cellForItem(at: index) as? BarCollectionViewCell {
			cell.transformToLarge()
		}
		
		// Not already a visible cell in which case we need to let datasource
		// know which to enlarge when it does become visible
		if let source = dataSource as? BarCollectionDataSource {
			source.indexOfFocus = index
		}
		scrollToItem(at: index, at: .centeredHorizontally, animated: false)
		
	}

}
