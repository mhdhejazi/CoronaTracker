//
//  TodayViewController.swift
//  CoronaTrackerWidget
//
//  Created by Piotr Ożóg on 12/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import NotificationCenter

import CoronaData

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet var worldwideTitleLabel: UILabel!
    @IBOutlet var confirmedCountLabel: UILabel!
    @IBOutlet var recoveredCountLabel: UILabel!
    @IBOutlet var deathsCountLabel: UILabel!
    @IBOutlet var confirmedLabel: UILabel!
    @IBOutlet var recoveredLabel: UILabel!
    @IBOutlet var deathsLabel: UILabel!
    @IBOutlet var dataViews: [UIView]!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupStyle()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        activityIndicatorView.startAnimating()
        DataManager.instance.download { [weak self] success in
            completionHandler(success ? NCUpdateResult.newData : NCUpdateResult.failed)
            DataManager.instance.load { [weak self] (success) in
                self?.activityIndicatorView.stopAnimating()
                self?.dataViews.forEach({ $0.isHidden = false })
                self?.showData(worldwideReport: DataManager.instance.worldwideReport)
            }
        }
    }

    private func showData(worldwideReport: Report?) {
        guard let worldwideReport = worldwideReport else {
            return
        }
        confirmedCountLabel.text = String(format: "%d", worldwideReport.stat.confirmedCount)
        recoveredCountLabel.text = String(format: "%d", worldwideReport.stat.recoveredCount)
        deathsCountLabel.text = String(format: "%d", worldwideReport.stat.deathCount)
    }

    private func setupStyle() {
        worldwideTitleLabel.textColor = .white
        confirmedCountLabel.textColor = .white
        recoveredCountLabel.textColor = .white
        deathsCountLabel.textColor = .white
        confirmedLabel.textColor = .white
        recoveredLabel.textColor = .white
        deathsLabel.textColor = .white
        dataViews.forEach { (view) in
            view.layer.cornerRadius = 5
            view.layer.masksToBounds = true
            view.isHidden = true
        }
    }
}
