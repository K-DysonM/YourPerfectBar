//
//  BarCollectionViewCell.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit

class BarCollectionViewCell: UICollectionViewCell {
	@IBOutlet var barTitleLabel: UILabel!
	@IBOutlet var barImageView: UIImageView!
	
	
	var imageView: UIImageView!
	var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		layer.cornerRadius = 5.0
    }
	func transformToLarge() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: []) {
			self.transform = CGAffineTransform(scaleX: 1, y: 1.1)
		}
	}

	func transformToOriginal() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: []) {
			self.transform = CGAffineTransform(scaleX: 1, y: 1)
		}
	}
	

}
