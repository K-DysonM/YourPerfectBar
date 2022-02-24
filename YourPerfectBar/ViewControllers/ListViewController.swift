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
import Combine

class ListViewController: UITableViewController {
	var bars = [CDYelpBusiness]()
	var barsViewModel: BarsViewModel!
	private var cancellables: Set<AnyCancellable> = []

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(updateTableView), for: .valueChanged)
		tableView.backgroundColor = .systemBackground
		barsViewModel.$currentBars.sink { [weak self] bars in
			self?.bars = bars
			self?.updateTableViewUI()
		
		}.store(in: &cancellables)
	}
	@objc
	func showMapView() {
		tabBarController?.selectedIndex = 0
	}
	
	@objc func updateTableView() {
		tableView.reloadData()
		tableView.refreshControl?.endRefreshing()
	}
	func updateTableViewUI() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	// TABLEVIEW METHODS
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		bars.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "BarTableViewCell", for: indexPath) as? BarTableViewCell else { fatalError("BarTableViewCell not properly initialized") }
		let bar = bars[indexPath.row]
		cell.update(for: (bar.name, bar.displayPhone))
		cell.barImageView.contentMode = .scaleAspectFill
		#warning("Look into if the preferred way is to have direct access to the imageView like this")
		cell.barImageView.sd_setImage(with: bar.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		return cell
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = BarDetailViewController()
		vc.barInformation = bars[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}

}
