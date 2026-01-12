import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("workDuration") private var workDurationSeconds: Int = 25 * 60
    @AppStorage("restDuration") private var restDurationSeconds: Int = 5 * 60
    @AppStorage("reminderTime") private var reminderTimeSeconds: Int = 5 * 60

    @State private var workMinutes: Int = 25
    @State private var restMinutes: Int = 5
    @State private var reminderMinutes: Int = 5
    @State private var launchAtLogin: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 工作时长
            VStack(alignment: .leading, spacing: 8) {
                Text("工作时长")
                    .font(.headline)

                HStack {
                    TextField("", value: $workMinutes, formatter: minuteFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .onChange(of: workMinutes) { newValue in
                            workDurationSeconds = max(1, newValue) * 60
                        }

                    Text("分钟")
                        .foregroundColor(.secondary)
                }
            }

            // 休息时长
            VStack(alignment: .leading, spacing: 8) {
                Text("休息时长")
                    .font(.headline)

                HStack {
                    TextField("", value: $restMinutes, formatter: minuteFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .onChange(of: restMinutes) { newValue in
                            restDurationSeconds = max(1, newValue) * 60
                        }

                    Text("分钟")
                        .foregroundColor(.secondary)
                }
            }

            // 提醒时间
            VStack(alignment: .leading, spacing: 8) {
                Text("提前提醒时间")
                    .font(.headline)

                HStack {
                    TextField("", value: $reminderMinutes, formatter: minuteFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                        .onChange(of: reminderMinutes) { newValue in
                            let validValue = min(max(1, newValue), workMinutes - 1)
                            reminderTimeSeconds = validValue * 60
                            if newValue != validValue {
                                reminderMinutes = validValue
                            }
                        }

                    Text("分钟")
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Toggle("开机自动启动", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    setLaunchAtLogin(newValue)
                }

            Spacer()

            Text("锁屏后计时器会自动重置")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
        }
        .padding(20)
        .frame(width: 260, height: 320)
        .onAppear {
            workMinutes = workDurationSeconds / 60
            restMinutes = restDurationSeconds / 60
            reminderMinutes = reminderTimeSeconds / 60
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private var minuteFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimum = 1
        return formatter
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("设置开机启动失败: \(error)")
        }
    }
}
