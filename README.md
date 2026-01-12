# RestReminder

macOS 菜单栏应用，帮助你控制单次使用 MacBook 的时长，强制休息保护健康。

## 功能特性

- ⏱️ **工作计时**：监控从解锁或休息结束开始的使用时间
- 🔔 **提前提醒**：到期前 5 分钟发送系统通知，允许主动收尾
- 🚫 **强制休息**：超时后全屏显示休息界面，阻止操作直到休息结束
- 🔒 **自动重置**：锁屏、休眠或屏保结束后自动重置计时器
- ⚙️ **灵活配置**：自定义工作时长、休息时长和提醒时间
- 📊 **菜单栏显示**：简洁显示剩余时间（如 `25m`）

## 系统要求

- macOS 13.0 或更高版本
- Xcode 14.0 或更高版本（用于构建）

## 安装

### 方式一：命令行编译安装

```bash
# 克隆项目
git clone https://github.com/zync-mzy/rest-reminder.git
cd rest-reminder

# 编译 Release 版本
xcodebuild -project RestReminder.xcodeproj -scheme RestReminder -configuration Release -derivedDataPath build build

# 安装到应用程序目录
cp -R build/Build/Products/Release/RestReminder.app /Applications/
```

### 方式二：Xcode 编译

1. 打开 `RestReminder.xcodeproj`
2. 选择 `RestReminder` scheme
3. 菜单栏 Product → Archive，或直接 `⌘R` 运行
4. 将生成的 `.app` 文件拖入 `/Applications/` 目录

## 使用说明

### 首次启动

1. 应用启动后会在菜单栏显示剩余时间
2. 首次运行时会请求通知权限，请允许以接收提醒
3. 默认配置：工作 25 分钟，休息 5 分钟，提前 5 分钟提醒

### 配置设置

点击菜单栏图标 → 偏好设置，可以调整：

- **工作时长**：单次使用的最大分钟数（默认 25 分钟）
- **休息时长**：强制休息的分钟数（默认 5 分钟）
- **提醒时间**：提前多久发送提醒（默认 5 分钟）

### 工作流程

1. **工作阶段**：菜单栏显示剩余时间，倒计时进行
2. **提前提醒**：剩余 5 分钟时收到系统通知
   - 可点击"立即休息"按钮提前进入休息
   - 或继续工作直到时间到达
3. **强制休息**：时间到后全屏显示休息界面
   - 显示休息倒计时
   - 提示站起来走动、眺望远方
   - 呼吸动画帮助放松
4. **重新开始**：休息结束后自动回到工作阶段

### 特殊功能

- **自动重置**：锁屏、合上屏幕或屏保结束后会重置计时器，重新开始计时
- **延长工作时间**：如需延长，可通过锁屏再解锁的方式重置计时
- **屏保联动**：休息结束后启动系统屏保，建议在系统设置中开启"屏保后需要密码"以获得最佳体验

## 项目结构

```
RestReminder/
├── RestReminderApp.swift    # App 入口
├── AppDelegate.swift         # 应用代理，菜单栏和系统事件处理
├── TimerManager.swift        # 计时器核心逻辑
├── RestView.swift            # 强制休息全屏界面
├── SettingsView.swift        # 偏好设置界面
├── Assets.xcassets/          # 资源文件
└── Info.plist               # 应用配置
```

## 技术栈

- **SwiftUI**：现代化 UI 框架
- **AppKit**：macOS 原生框架（菜单栏、窗口管理）
- **UserNotifications**：系统通知
- **NSWorkspace**：系统事件监听

## 核心机制

### 计时器逻辑

- 使用 `Timer` 每秒更新一次
- 追踪 `elapsedSeconds`（已使用时间）
- 计算 `remainingSeconds`（剩余时间）
- 状态切换：`working` ↔ `resting`

### 系统事件监听

监听以下事件，唤醒时重置计时器：
- `screensDidSleepNotification`：屏幕休眠
- `willSleepNotification`：系统休眠
- `com.apple.screenIsUnlocked`：屏幕解锁
- `screensDidWakeNotification`：屏幕唤醒（包括屏保结束）

### 强制休息

- 创建 `NSWindow`，level 设为 `.screenSaver`
- 全屏覆盖，阻止用户操作
- 显示倒计时和鼓励文案
- 休息结束启动系统屏保

## 开发说明

### 调试

- 修改默认时长为更短的值便于测试（如 1 分钟工作，30 秒休息）
- 在 `TimerManager.swift` 中调整默认值

### 自启动

Info.plist 中已设置 `LSUIElement = true`，应用不会在 Dock 显示，只在菜单栏运行。

如需开机自启动，可在系统设置 → 通用 → 登录项中添加。

## 许可

MIT License

## 反馈

如有问题或建议，欢迎提 Issue。
