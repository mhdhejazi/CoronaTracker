//
//  Corona Tracker
//  Created by Mhd Hejazi on 4/3/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class ChartController: UIViewController {
	@IBOutlet private var effectViewBackground: UIVisualEffectView!
	@IBOutlet private var effectViewHeader: UIVisualEffectView!
	@IBOutlet private var labelTitle: UILabel!
	@IBOutlet private var labelTime: UILabel!
	@IBOutlet private var imageLogo: UIImageView!
	@IBOutlet private var chartViewContainer: UIView!

	private var chartView: RegionChartView!
	private var contextMenu: ContextMenu?

	var sourceChartView: RegionChartView!

	override var keyCommands: [UIKeyCommand]? {
		[UIKeyCommand(input: UIKeyCommand.inputEscape,
							 modifierFlags: [],
							 action: #selector(doneButtonTapped(_:)))]
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		#if targetEnvironment(macCatalyst)
		self.modalPresentationStyle = .overFullScreen
		self.modalTransitionStyle = .crossDissolve
		#endif
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let fontScale: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 1 : 1.3

		let chartViewType = type(of: sourceChartView) as RegionChartView.Type
		chartView = chartViewType.init(fontScale: fontScale)
		chartViewContainer.addSubview(chartView)
		chartView.snapEdgesToSuperview()
		chartView.interactive = true
		chartView.shareAction = shareImage
		chartView.updateOptions(from: sourceChartView)
		chartView.update(region: sourceChartView.region, animated: true)

		if #available(iOS 11.0, *) {
			labelTitle.font = .preferredFont(forTextStyle: .largeTitle)
		} else {
			labelTitle.font = .boldSystemFont(ofSize: 24)
		}
		labelTitle.text = (chartViewType == TopChartView.self) ? L10n.Region.world : sourceChartView.region?.localizedName
		labelTime.text = sourceChartView.region?.report?.lastUpdate.relativeTimeString

		if #available(iOS 13.0, *) {
			effectViewBackground.effect = UIBlurEffect(style: .systemMaterial)
			effectViewHeader.effect = UIBlurEffect(style: .systemMaterial)
		}

		contextMenu = ContextMenu(view: view, menuBuilder: self)
	}

	private func createShareImage() -> UIImage? {
		var image: UIImage?
		chartView.prepareForShare {
			image = self.view.snapshot()
		}

		let imageBounds = CGRect(origin: .zero, size: image?.size ?? .zero)
		image = UIGraphicsImageRenderer(bounds: imageBounds).image { rendererContext in
			SystemColor.secondarySystemBackground.setFill()
			rendererContext.fill(imageBounds)

			image?.draw(at: .zero)
		}

		return image
	}

	private func shareImage() {
		ShareManager.shared.share(image: createShareImage(),
									text: chartView.shareableText,
									sourceView: self.view)
	}

	private func copyImage() {
		UIPasteboard.general.image = createShareImage()
	}

	// MARK: - Actions

	@IBAction private func doneButtonTapped(_ sender: Any) {
		dismiss(animated: true)
	}
}

@available(iOS 13.0, *)
extension ChartController: ContextMenuBuilder {
	func buildContextMenu() -> UIMenu? {
		var actions = chartView.contextMenuActions

		#if targetEnvironment(macCatalyst)
		actions.append(UIMenu(title: "", options: .displayInline, children: [
			UIAction(title: L10n.Menu.copy) { _ in self.copyImage() }
		]))
		#endif

		actions.append(UIAction(title: L10n.Menu.share, image: Asset.share.image) { _ in
			self.shareImage()
		})

		return UIMenu(title: "", children: actions)
	}
}
