//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/8/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class DetailsView: UIView {
	private lazy var titleLabel: UILabel! = {
		let label = UILabel()
		label.textColor = .systemGray
		label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .footnote), size: 0)
		label.text = "\(L10n.Case.confirmed):\n\(L10n.Case.active):\n\(L10n.Case.recovered):\n\(L10n.Case.deaths):"
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	lazy var detailsLabel: UILabel! = {
		let label = UILabel()
		label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .footnote), size: 0)
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override var forFirstBaselineLayout: UIView { titleLabel }
	override var forLastBaselineLayout: UIView { titleLabel }

	init() {
		super.init(frame: .zero)

		initializeView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func initializeView() {
		addSubview(titleLabel)
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		titleLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		addSubview(detailsLabel)
		detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		detailsLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

		titleLabel.trailingAnchor.constraint(equalTo: detailsLabel.leadingAnchor, constant: -5).isActive = true
	}
}
