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
	
	func update(for bar: (title: String?, subtitle: String?)) {
		barTitleLabel.text = bar.title
		barSubtitleLabel.text = bar.subtitle
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
