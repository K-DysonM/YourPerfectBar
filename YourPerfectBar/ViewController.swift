//
//  ViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit
import CDYelpFusionKit
import SDWebImage
import MapKit

class ViewController: UITableViewController {
	let yelpAPIClient = CDYelpAPIClient(apiKey: Configuration().yelpApiKey)
	var bars = [CDYelpBusiness]()
	var barsModel: BarsModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(updateTableView), for: .valueChanged)
		searchForBarsAt(coordinate: nil, location: "New York City")
	}
	func searchForBarsAt(coordinate: CLLocationCoordinate2D?, location: String?) {
		DispatchQueue.global().async {
			self.yelpAPIClient.searchBusinesses(
				byTerm: "bars",
				location: location,
				latitude: coordinate?.latitude,
				longitude: coordinate?.longitude,
				radius: 5000,
				categories: nil,
				locale: .english_unitedStates,
				limit: 5,
				offset: nil,
				sortBy: .bestMatch,
				priceTiers: nil,
				openNow: nil,
				openAt: nil,
				attributes: nil) {[self] cdYelpSearchResponse in
				guard let businesses = cdYelpSearchResponse?.businesses else { return }
				self.barsModel.bars = businesses
				
				performSelector(onMainThread: #selector(self.updateTableView), with: nil, waitUntilDone: false)
			}
		}
	}
	
	@objc func updateTableView() {
		tableView.reloadData()
		tableView.refreshControl?.endRefreshing()
		
	}

	// TABLEVIEW METHODS
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		barsModel.bars.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BarTableViewCell", for: indexPath) as? BarTableViewCell else {  fatalError("BarTableViewCell not properly initialized") }
		let bar = barsModel.bars[indexPath.row]
		cell.update(for: (bar.name, bar.displayPhone))
		// If not a valid url the placeholder image will be used - Without a placeholder image the imageView will show blank
		cell.barImageView.contentMode = .scaleAspectFill
		#warning("Look into if the preferred way is to have direct access to the imageView like this")
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = BarDetailViewController()
		vc.barInformation = barsModel.bars[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}

}
