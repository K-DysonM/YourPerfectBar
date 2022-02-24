//
//  BarTableViewCell.swift
//  YourPerfectBar
//
//  Created by Kiana Dyson on 1/28/22.
//

import UIKit

class BarTableViewCell: UITableViewCell {

	@IBOutlet var barImageView: UIImageView!
	@IBOutlet private var barTitleLabel: UILabel!
	@IBOutlet private var barSubtitleLabel: UILabel!
	@IBOutlet private var barTypeImageView: UIImageView!
	@IBOutlet var containerView: UIView!
	
	func update(for bar: (title: String?, subtitle: String?)) {
		barTitleLabel.text = bar.title 
		if let subtitle = bar.subtitle, subtitle.isEmpty {
			barSubtitleLabel.text = "N/A"
		} else {
			barSubtitleLabel.text = bar.subtitle
		}
		barTypeImageView.image = UIImage(named: "beerIcon")
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	

}
