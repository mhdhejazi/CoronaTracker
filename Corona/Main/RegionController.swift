//
//  RegionController.swift
//  Corona
//
//  Created by Mohammad on 3/4/20.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import SafariServices

import Charts

class RegionController: UITableViewController {
	var virusReport: VirusReport? {
		didSet {
			if virusReport == nil {
				virusReport = VirusDataManager.instance.globalReport
				return
			}

			virusTimeSeries = VirusDataManager.instance.timeSeries(for: virusReport!.region)
		}
	}
	private var virusTimeSeries: VirusTimeSeries?

	@IBOutlet var labelTitle: UILabel!
	@IBOutlet var labelConfirmed: UILabel!
	@IBOutlet var labelRecovered: UILabel!
	@IBOutlet var labelDeaths: UILabel!
	@IBOutlet var chartViewCurrent: PieChartView!
	@IBOutlet var chartViewTimeSeries: LineChartView!
	@IBOutlet var labelUpdated: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .clear

		initializeCurrentChart()
		initializeTimeSeriesChart()

		virusReport = VirusDataManager.instance.globalReport

		update()
    }

	override func didMove(toParent parent: UIViewController?) {
		super.didMove(toParent: parent)

		updateParent()
	}

	private func initializeCurrentChart() {
		let chartView = chartViewCurrent!

		chartView.usePercentValuesEnabled = true
		chartView.holeColor = nil
		chartView.rotationAngle = 0
		chartView.drawEntryLabelsEnabled = false
		chartView.setExtraOffsets(left: 0, top: 5, right: 0, bottom: -10)

		initializeLegent(chartView.legend)
	}

	private func initializeTimeSeriesChart() {

		let chartView = chartViewTimeSeries!

//		chartView.xAxis.drawGridLinesEnabled = false
		chartView.xAxis.gridColor = .lightGray
		chartView.xAxis.labelPosition = .bottom
		chartView.xAxis.gridLineDashLengths = [3, 3]
		chartView.xAxis.labelTextColor = .systemGray
		chartView.xAxis.valueFormatter = DayAxisValueFormatter(chart: chartView)

//		chartView.leftAxis.drawGridLinesEnabled = false
		chartView.leftAxis.gridLineDashLengths = [3, 3]
		chartView.leftAxis.gridColor = .lightGray
		chartView.leftAxis.labelTextColor = .systemGray
		chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter() { value, axis in
			value.kmFormatted
		}

		chartView.rightAxis.enabled = false

//		chartView.dragEnabled = false
//		chartView.scaleXEnabled = false
		chartView.scaleYEnabled = false

		let marker = XYMarkerView(color: UIColor.darkGray.withAlphaComponent(0.75),
								  font: .boldSystemFont(ofSize: 13),
								  textColor: .white,
								  insets: UIEdgeInsets(top: 8, left: 10, bottom: 23, right: 10),
								  xAxisValueFormatter: chartView.xAxis.valueFormatter!)

		marker.arrowSize = CGSize(width: 15, height: 15)
//		marker.offset = CGPoint(x: 0, y: -10)
		marker.chartView = chartView
		marker.minimumSize = CGSize(width: 80, height: 40)
		chartView.marker = marker

		initializeLegent(chartView.legend)
	}

	private func initializeLegent(_ legend: Legend) {
		legend.textColor = .systemGray
		legend.font = .systemFont(ofSize: 12, weight: .regular)
		legend.form = .circle
		legend.formSize = 12
		legend.horizontalAlignment = .center
		legend.xEntrySpace = 10
	}

	func update() {
		UIView.transition(with: view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
			self.labelTitle.text = self.virusReport?.region.name
			self.labelConfirmed.text = self.virusReport?.data.confirmedCountString
			self.labelRecovered.text = self.virusReport?.data.recoveredCountString
			self.labelDeaths.text = self.virusReport?.data.deathCountString
			self.labelUpdated.text = "Last updated: \(self.virusReport?.hourAge ?? 0) hours ago"
		}, completion: nil)

		updateParent()

		updateCurrentChartData()
		updateTimeSeriesChartData()
	}

	func updateParent() {
		(parent as? RegionContainerController)?.update(report: virusReport)
	}

	private func updateCurrentChartData() {
		guard let report = virusReport else { return }

		var dataEntries: [PieChartDataEntry] = []
		dataEntries.append(PieChartDataEntry(value: Double(report.data.existingCount), label: "Existing"))
		dataEntries.append(PieChartDataEntry(value: Double(report.data.deathCount), label: "Deaths"))
		dataEntries.append(PieChartDataEntry(value: Double(report.data.recoveredCount), label: "Recovered"))

		let dataSet = PieChartDataSet(entries: dataEntries, label: "")
		dataSet.colors = [.systemGray, .systemRed, .systemGreen]
		dataSet.sliceSpace = 2
		dataSet.xValuePosition = .outsideSlice
		dataSet.yValuePosition = .insideSlice
		dataSet.valueTextColor = .white
		dataSet.entryLabelColor = .black
		dataSet.valueFont = .systemFont(ofSize: 13, weight: .heavy)
		dataSet.valueFormatter = PercentValueFormatter()

		chartViewCurrent.data = PieChartData(dataSet: dataSet)

		chartViewCurrent.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
	}

	private func updateTimeSeriesChartData() {
		guard let series = virusTimeSeries else { return }

		let dates = series.series.keys.sorted()
		let confirmedEntries = dates.map {
			ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.confirmedCount ?? 0))
		}
		let recoveredEntries = dates.map {
			ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.recoveredCount ?? 0))
		}
		let deathsEntries = dates.map {
			ChartDataEntry(x: Double($0.referenceDays), y: Double(series.series[$0]?.deathCount ?? 0))
		}

		let entries = [confirmedEntries, deathsEntries, recoveredEntries]
		let labels = ["Confirmed", "Deaths", "Recovered"]
		let colors = [UIColor.systemOrange, .systemRed, .systemGreen]

		var dataSets = [LineChartDataSet]()
		for i in entries.indices {
			let dataSet = LineChartDataSet(entries: entries[i], label: labels[i])
			dataSet.mode = .cubicBezier
//			dataSet.drawCirclesEnabled = false
			dataSet.drawCircleHoleEnabled = false
			dataSet.circleRadius = 2
			dataSet.circleColors = [colors[i].withAlphaComponent(0.5)]
			dataSet.circleHoleRadius = 1
			dataSet.drawValuesEnabled = false
			dataSet.lineWidth = 1
			dataSet.highlightLineWidth = 0
			dataSet.colors = [colors[i]]

			dataSets.append(dataSet)
		}

		chartViewTimeSeries.data = LineChartData(dataSets: dataSets)

		chartViewTimeSeries.animate(xAxisDuration: 2)
	}

	@IBAction func buttonInfoTapped(_ sender: Any) {
		let url = URL(string: "https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6")!
		let safariController = SFSafariViewController(url: url)
		safariController.modalPresentationStyle = .formSheet
		present(safariController, animated: true)
	}
}
