//
//  SynchronizationManager.swift
//  Corona Tracker
//
//  Created by Piotr Ożóg on 02/04/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import UserNotifications

final class SynchronizationManager {

    private let notificationCenter = UNUserNotificationCenter.current()

    func configure() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DataManager.instance.download { [weak self] success in
            guard success else {
                completionHandler(.failed)
                return
            }
            DataManager.instance.load { [weak self] success in
                self?.createLocalNotification(for: DataManager.instance.world)
                completionHandler(success ? .newData : .failed)
            }
        }
    }

    func resetBadges() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    func createLocalNotification(for region: Region) {

        guard let stats = region.report?.stat else {
            return
        }
        let content = UNMutableNotificationContent()

        content.title = "\(region.name)"

        let confirmed = L10n.Case.confirmed + ": " + stats.confirmedCountString
        let recovered = L10n.Case.recovered + ": " + stats.recoveredCountString
        let deaths = L10n.Case.deaths + ": " + stats.deathCountString

        content.body = "\(confirmed)\n\(recovered)\n\(deaths)"

        content.sound = UNNotificationSound.default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: region.name, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
