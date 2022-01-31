//
//  ViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit
import CDYelpFusionKit
import SDWebImage

class ViewController: UITableViewController {
	let yelpAPIClient = CDYelpAPIClient(apiKey: Configuration().yelpApiKey)
	var bars = [CDYelpBusiness]()
	var barsModel: BarsModel!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		#warning("api calls should be moved off main thread")
		tableView.refreshControl = UIRefreshControl()
		tableView.refreshControl?.addTarget(self, action: #selector(updateTableView), for: .valueChanged)
		
		yelpAPIClient.searchBusinesses(
			byTerm: "bars",
			location: "New York City",
			latitude: nil,
			longitude: nil,
			radius: 5000,
			categories: nil,
			locale: .english_unitedStates,
			limit: 20,
			offset: nil,
			sortBy: .bestMatch,
			priceTiers: nil,
			openNow: nil,
			openAt: nil,
			attributes: nil) { [weak self] cdYelpSearchResponse in
			guard let businesses = cdYelpSearchResponse?.businesses else { return }
			self?.barsModel.bars = businesses
			self?.tableView.reloadData()
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
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BarTableViewCell", for: indexPath) as? BarTableViewCell else { return UITableViewCell() }
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
