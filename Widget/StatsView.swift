//
//  StatsView.swift
//  Widget
//
//  Created by Piotr Ożóg on 18/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit

class StatsView: UIView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var confirmedCountLabel: UILabel!
    @IBOutlet var recoveredCountLabel: UILabel!
    @IBOutlet var deathsCountLabel: UILabel!
    @IBOutlet var dataViews: [UIView]!
    @IBOutlet var dataLabels: [UILabel]!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var updateTimeLabel: UILabel!

    static let numberPercentSwitchInterval: TimeInterval = 3 /// Seconds
    private var showPercents = false
    private var switchPercentsTask: DispatchWorkItem?

    var isUpdatingData: Bool = true {
        didSet{
            isUpdatingData ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
            updateTimeLabel.isHidden = isUpdatingData
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initializeView()
    }

    private func initializeView() {
        dataViews.forEach { view in
            view.layer.cornerRadius = 8
        }
        dataLabels.forEach { label in
            label.textColor = .white
        }
        updateTimeLabel.textColor = SystemColor.secondaryLabel
        if #available(iOSApplicationExtension 13.0, *) {
            activityIndicatorView.style = .medium
        }
    }

    func update(report: Report?) {
        guard let report = report else {
            return
        }

        transition { [weak self] in
            self?.confirmedCountLabel.text = report.stat.confirmedCountString
            self?.recoveredCountLabel.text = report.stat.recoveredCountString
            self?.deathsCountLabel.text = report.stat.deathCountString
            self?.updateTimeLabel.text = report.lastUpdate.relativeTimeString
        }

        updateStats(report: report)
    }

    private func updateStats(report: Report?, reset: Bool = false) {
        switchPercentsTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.showPercents = !(self?.showPercents ?? false)
            self?.updateStats(report: report)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.numberPercentSwitchInterval, execute: task)
        switchPercentsTask = task

        if reset {
            showPercents = false
            return
        }

        guard let report = report else { return }
        recoveredCountLabel.transition { [weak self] in
            self?.recoveredCountLabel.text = self?.showPercents == true ?
                report.stat.recoveredPercent.percentFormatted :
                report.stat.recoveredCountString
        }
        deathsCountLabel.transition { [weak self] in
            self?.deathsCountLabel.text = self?.showPercents == true ?
                report.stat.deathPercent.percentFormatted :
                report.stat.deathCountString
        }
    }
}
