//
//  BarDetailViewController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit
import CDYelpFusionKit
import SDWebImage

class BarDetailViewController: UIViewController {
	var barImage: UIImageView!
	var barName: UILabel!
	var barNumber: UILabel!
	var barInformation: CDYelpBusiness?
	
	override func loadView() {
		view = UIView()
		view.backgroundColor = .white
		barImage = UIImageView()
		barImage.contentMode = .scaleAspectFill
		barImage.clipsToBounds = true
		barImage.translatesAutoresizingMaskIntoConstraints = false
		
		barName = UILabel()
		barName.textAlignment = .center
		#warning("Switched to Headline instead of built in number")
		barName.font = UIFont.systemFont(ofSize: 24.00)
		barName.numberOfLines = 0
		barName.text = "MY BAR"
		barName.translatesAutoresizingMaskIntoConstraints = false
		
		barNumber = UILabel()
		barNumber.textAlignment = .center
		#warning("Switched to paragraph instead of built in number")
		barNumber.font = UIFont.systemFont(ofSize: 18.00)
		barNumber.numberOfLines = 0
		barNumber.text = "111-111-1111"
		barNumber.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(barImage)
		view.addSubview(barName)
		view.addSubview(barNumber)
		
		NSLayoutConstraint.activate(
			[barImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			 barImage.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
			 barImage.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
			 barImage.heightAnchor.constraint(equalToConstant: 200),
			 barName.topAnchor.constraint(equalTo: barImage.bottomAnchor,constant: 10.00),
			 barName.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			 barName.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			 barNumber.topAnchor.constraint(equalTo: barName.bottomAnchor, constant: 10.00), 
			 barNumber.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			 barNumber.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
			])
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		guard let barInformation = barInformation else { return }
		barImage.sd_setImage(with: barInformation.imageUrl, placeholderImage: UIImage(systemName: "music.house"))
		barName.text = barInformation.name
		barNumber.text = barInformation.displayPhone
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showShare))
	}
	
	@objc func showShare() {
		guard let url = barInformation?.url else { return }
		let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
		present(ac, animated: true, completion: nil)
	}

}
