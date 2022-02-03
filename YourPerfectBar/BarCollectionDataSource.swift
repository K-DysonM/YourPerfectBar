//
//  BarCollectionDataSource.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 2/3/22.
//

import UIKit
import CDYelpFusionKit

class BarCollectionDataSource: NSObject, UICollectionViewDataSource {
	var objects = [CDYelpBusiness]()
	
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
		#warning("Look into if the preferred way is to have direct access to the imageView like this")
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
}
