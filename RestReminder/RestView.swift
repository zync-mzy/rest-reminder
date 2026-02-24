import SwiftUI

struct RestView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                // 休息提示
                Text("伏案久了，休息一下")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                // 倒计时显示
                Text(formatTime(timerManager.remainingSeconds))
                    .font(.system(size: 96, weight: .light))
                    .foregroundColor(.white)

                // 鼓励文案
                Text("已工作 \(timerManager.workDuration / 60) 分钟")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))

                Text("站起来走动走动，眺望远方")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.6))

                // 呼吸动画
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(breathingScale)
                    .animation(
                        Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                        value: breathingScale
                    )
                    .onAppear {
                        breathingScale = 1.3
                    }
            }
        }
    }

    @State private var breathingScale: CGFloat = 1.0

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
