// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum App {
    /// Credits
    internal static let credits = L10n.tr("Localizable", "app.credits")
    /// Please update from %@
    internal static func newVersionMessage(_ p1: String) -> String {
      return L10n.tr("Localizable", "app.newVersionMessage", p1)
    }
    /// New Version Available
    internal static let newVersionTitle = L10n.tr("Localizable", "app.newVersionTitle")
  }

  internal enum Case {
    /// Active
    internal static let active = L10n.tr("Localizable", "case.active")
    /// Confirmed
    internal static let confirmed = L10n.tr("Localizable", "case.confirmed")
    /// Deaths
    internal static let deaths = L10n.tr("Localizable", "case.deaths")
    /// Recovered
    internal static let recovered = L10n.tr("Localizable", "case.recovered")
  }

  internal enum Chart {
    /// Daily New Cases
    internal static let delta = L10n.tr("Localizable", "chart.delta")
    /// Growth of Cases
    internal static let history = L10n.tr("Localizable", "chart.history")
    /// Logarithmic Scale
    internal static let logarithmic = L10n.tr("Localizable", "chart.logarithmic")
    /// Most Affected Countries
    internal static let topCountries = L10n.tr("Localizable", "chart.topCountries")
    /// Most Affected Regions
    internal static let topRegions = L10n.tr("Localizable", "chart.topRegions")
    /// Confirmed cases since 100th case
    internal static let trendline = L10n.tr("Localizable", "chart.trendline")
    internal enum Axis {
      /// %d Days
      internal static func days(_ p1: Int) -> String {
        return L10n.tr("Localizable", "chart.axis.days", p1)
      }
    }
    internal enum Delta {
      /// Daily New Deaths
      internal static let deaths = L10n.tr("Localizable", "chart.delta.deaths")
      /// Decreasing
      internal static let decreasing = L10n.tr("Localizable", "chart.delta.decreasing")
      /// Increasing
      internal static let increasing = L10n.tr("Localizable", "chart.delta.increasing")
    }
    internal enum Trendline {
      /// Deaths since 10th death
      internal static let deaths = L10n.tr("Localizable", "chart.trendline.deaths")
    }
  }

  internal enum Data {
    /// Please make sure you're connected to the internet.
    internal static let errorMessage = L10n.tr("Localizable", "data.errorMessage")
    /// Can't update the data
    internal static let errorTitle = L10n.tr("Localizable", "data.errorTitle")
    /// Source: %@
    internal static func source(_ p1: String) -> String {
      return L10n.tr("Localizable", "data.source", p1)
    }
    /// Last updated:
    internal static let updateDate = L10n.tr("Localizable", "data.updateDate")
    /// Updating...
    internal static let updating = L10n.tr("Localizable", "data.updating")
  }

  internal enum Menu {
    /// Copy
    internal static let copy = L10n.tr("Localizable", "menu.copy")
    /// Release Notes
    internal static let releaseNotes = L10n.tr("Localizable", "menu.releaseNotes")
    /// Report an Issue
    internal static let reportIssue = L10n.tr("Localizable", "menu.reportIssue")
    /// Search
    internal static let search = L10n.tr("Localizable", "menu.search")
    /// Share
    internal static let share = L10n.tr("Localizable", "menu.share")
    /// Update
    internal static let update = L10n.tr("Localizable", "menu.update")
  }

  internal enum Message {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "message.cancel")
    /// Done
    internal static let done = L10n.tr("Localizable", "message.done")
    /// OK
    internal static let ok = L10n.tr("Localizable", "message.ok")
    /// Open
    internal static let `open` = L10n.tr("Localizable", "message.open")
  }

  internal enum Region {
    /// Worldwide
    internal static let world = L10n.tr("Localizable", "region.world")
  }

  internal enum Share {
    /// Coronavirus growth chart
    internal static let chartHistory = L10n.tr("Localizable", "share.chartHistory")
    /// Coronavirus live update
    internal static let current = L10n.tr("Localizable", "share.current")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
