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
	var crasjdlslahsHJJSDH = ""

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		#warning("api calls should be moved off main thread")
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
			self?.bars = businesses
			self?.tableView.reloadData()
		}
	}

	// TABLEVIEW METHODS
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		bars.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		#warning("Change cell to a custom cell")
		let cell = tableView.dequeueReusableCell(withIdentifier: "Bar", for: indexPath)
		let bar = bars[indexPath.row]
		cell.textLabel?.text = bar.name
		cell.detailTextLabel?.text = bar.displayPhone
		// If not a valid url the placeholder image will be used - Without a placeholder image the imageView will show blank
		cell.imageView?.contentMode = .scaleAspectFill
		cell.imageView?.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		#warning("Need to set up a view controller show bar detail information")
		if let name = bars[indexPath.row].name {
			print("\(name) was clicked")
		} else {
			print("\(indexPath.row) was clicked")
		}
	}

}
