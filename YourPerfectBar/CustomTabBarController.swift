//
//  CustomTabBarController.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/29/22.
//

import UIKit

class CustomTabBarController: UITabBarController {

	
    override func viewDidLoad() {
        super.viewDidLoad()
		let barsViewModel = BarsViewModel()
		
		
		guard let vc = storyboard?.instantiateViewController(withIdentifier: "ListViewController") as? ListViewController else { return }
		guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
		let home = HomeViewController()
		
		
		vc.tabBarItem = .init(title: "List", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)
		vc1.tabBarItem = .init(title: "Map", image: UIImage(systemName: "map"), tag: 1)
		home.tabBarItem = .init(title: "Home", image: UIImage(systemName: "house"), tag: 2)
		vc.barsViewModel = barsViewModel
		vc1.barsViewModel = barsViewModel
		tabBar.tintColor = DEFAULT_TINT

		
		let nc = UINavigationController(rootViewController: vc)
		let nc1 = UINavigationController(rootViewController: vc1)
	
		viewControllers = [home, nc1, nc]
		tabBar.isHidden = false
        // Do any additional setup after loading the view.
    }

}
