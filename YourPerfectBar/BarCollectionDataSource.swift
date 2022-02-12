//
//  BarCollectionDataSource.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/3/22.
//

import UIKit
import CDYelpFusionKit

class BarCollectionDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
	var objects = [CDYelpBusiness]()
	var centerCell: BarCollectionViewCell?
	
	var indexOfFocus: IndexPath?

	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return objects.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Bar", for: indexPath) as? BarCollectionViewCell else {
			fatalError("BarCollectionViewCell not properly initialized")
		}
		let bar = objects[indexPath.item]
		cell.barTitleLabel.text = bar.name
		cell.barImageView.contentMode = .scaleAspectFill
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let cell = cell as? BarCollectionViewCell else { return }
		if let indexOfFocus = indexOfFocus {
			if indexOfFocus == indexPath {
				cell.transformToLarge()
				self.indexOfFocus = nil
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		print("SELECTED")
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard let collectionView = scrollView as? UICollectionView else { return }
		let centerPoint = CGPoint(x: collectionView.frame.size.width/2 + scrollView.contentOffset.x, y: collectionView.frame.size.height/2 + scrollView.contentOffset.y)

		if let centerCell = centerCell {
			let touchX = centerPoint.x - centerCell.center.x
			if (touchX < -150 || touchX > 150) && !centerCell.isAnimating {
				centerCell.transformToOriginal()
				self.centerCell = nil
			}
		}
		let indexPath = collectionView.indexPathForItem(at: centerPoint)
		if let indexPath = indexPath, self.centerCell == nil {
			centerCell = collectionView.cellForItem(at: indexPath) as? BarCollectionViewCell
			centerCell?.transformToLarge()
		}
		
	}
	
	
}
extension UIView {
	
	var isAnimating: Bool {
		return (self.layer.animationKeys()?.count ?? 0) > 0
	}
	
}
