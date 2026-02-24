import AppKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timerManager: TimerManager!
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)

        // 请求通知权限
        requestNotificationPermission()

        // 初始化计时器管理器
        timerManager = TimerManager()

        // 创建菜单栏图标
        setupMenuBar()

        // 开始计时
        timerManager.start()

        // 监听系统锁屏/休眠事件
        setupSystemEventListeners()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("通知权限请求失败: \(error)")
            }
        }

        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        updateMenuBarTitle()

        // 创建菜单
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "再冲一把", action: #selector(resetTimer), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "休息一下", action: #selector(startRestNow), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "偏好设置...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu

        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMenuBarTitle()
        }
        RunLoop.main.add(timer, forMode: .common)
    }

    private func updateMenuBarTitle() {
        guard let button = statusItem?.button else { return }

        let remaining = timerManager.remainingSeconds
        let minutes = remaining / 60

        // 设置图标
        if let clockImage = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "Timer") {
            clockImage.isTemplate = true
            button.image = clockImage
            button.imagePosition = .imageLeading
        }

        button.title = " \(minutes)m"
    }

    private func setupSystemEventListeners() {
        // 监听屏幕休眠
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenLock),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )

        // 监听系统休眠
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenLock),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )

        // 监听屏幕锁定（真正的锁屏）
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleScreenLock),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )

        // 监听屏幕解锁
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleScreenWake),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )

        // 监听屏幕唤醒（包括屏保结束）
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleScreenWake),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )
    }

    @objc private func handleScreenLock() {
        print("检测到锁屏/休眠")
    }

    @objc private func handleScreenWake() {
        print("检测到屏幕唤醒，重置计时器")
        timerManager.reset()
    }

    @objc private func resetTimer() {
        timerManager.reset()
    }

    @objc private func startRestNow() {
        timerManager.startRest()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "偏好设置"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 260, height: 320))
            settingsWindow?.center()
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "REST_NOW" {
            // 立即开始休息
            timerManager.startRest()
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
