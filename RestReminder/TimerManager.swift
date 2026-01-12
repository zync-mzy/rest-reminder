import Foundation
import UserNotifications
import AppKit
import SwiftUI

class TimerManager: ObservableObject {
    enum State {
        case working
        case resting
    }

    @Published var state: State = .working
    @Published var elapsedSeconds: Int = 0
    @Published var remainingSeconds: Int = 0

    // 从 UserDefaults 读取配置
    var workDuration: Int {
        UserDefaults.standard.integer(forKey: "workDuration") == 0 ? 25 * 60 : UserDefaults.standard.integer(forKey: "workDuration")
    }

    var restDuration: Int {
        UserDefaults.standard.integer(forKey: "restDuration") == 0 ? 5 * 60 : UserDefaults.standard.integer(forKey: "restDuration")
    }

    var reminderTime: Int {
        UserDefaults.standard.integer(forKey: "reminderTime") == 0 ? 5 * 60 : UserDefaults.standard.integer(forKey: "reminderTime")
    }

    private var timer: Timer?
    private var hasShownReminder = false
    private var restWindow: NSWindow?

    init() {
        remainingSeconds = workDuration
    }

    func start() {
        timer?.invalidate()
        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func reset() {
        elapsedSeconds = 0
        remainingSeconds = workDuration
        hasShownReminder = false
        state = .working
        hideRestWindow()
    }

    private func startScreenSaver() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/CoreServices/ScreenSaverEngine.app"))
    }

    func startRest() {
        state = .resting
        elapsedSeconds = 0
        remainingSeconds = restDuration
        hasShownReminder = false
        showRestWindow()
    }

    private func tick() {
        elapsedSeconds += 1

        switch state {
        case .working:
            remainingSeconds = max(0, workDuration - elapsedSeconds)

            // 检查是否需要发送提醒
            if remainingSeconds == reminderTime && !hasShownReminder {
                sendReminder()
                hasShownReminder = true
            }

            // 检查是否需要强制休息
            if remainingSeconds == 0 {
                startRest()
            }

        case .resting:
            if remainingSeconds > 0 {
                remainingSeconds = restDuration - elapsedSeconds
                if remainingSeconds == 0 {
                    startScreenSaver()
                }
            }
        }
    }

    private func sendReminder() {
        let content = UNMutableNotificationContent()
        content.title = "即将到达工作时长"
        content.body = "还有 \(reminderTime / 60) 分钟，建议保存工作并准备休息"
        content.sound = .default

        // 设置为时效性通知，显示时间更长
        if #available(macOS 12.0, *) {
            content.interruptionLevel = .timeSensitive
        }

        // 添加"立即休息"按钮
        let restAction = UNNotificationAction(identifier: "REST_NOW", title: "立即休息", options: .foreground)
        let category = UNNotificationCategory(identifier: "REST_REMINDER", actions: [restAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "REST_REMINDER"

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error)")
            }
        }
    }

    private func showRestWindow() {
        if restWindow == nil {
            let restView = RestView(timerManager: self)
            let hostingController = NSHostingController(rootView: restView)

            restWindow = NSWindow(contentViewController: hostingController)
            restWindow?.styleMask = [.borderless, .fullSizeContentView]
            restWindow?.level = .screenSaver
            restWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            restWindow?.backgroundColor = .black

            // 全屏显示
            if let screen = NSScreen.main {
                restWindow?.setFrame(screen.frame, display: true)
            }
        }

        restWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func hideRestWindow() {
        restWindow?.close()
        restWindow = nil
    }
}
