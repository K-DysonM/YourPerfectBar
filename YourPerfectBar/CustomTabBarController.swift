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
		let barModel = BarsModel()
		
		guard let vc = storyboard?.instantiateViewController(withIdentifier: "ListViewController") as? ViewController else { return }
		guard let vc1 = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else { return }
		
		
		vc.tabBarItem = .init(tabBarSystemItem: .bookmarks, tag: 0)
		vc1.tabBarItem = .init(tabBarSystemItem: .search, tag: 1)
		vc.barsModel = barModel
		vc1.barsModel = barModel
		
		let nc = UINavigationController(rootViewController: vc)
		let nc1 = UINavigationController(rootViewController: vc1)
		viewControllers = [nc, nc1]
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
