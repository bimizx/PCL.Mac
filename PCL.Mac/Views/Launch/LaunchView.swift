//
//  MainView.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

fileprivate struct ProgressModifier: AnimatableModifier {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        Text(String(format: "%.2f%%", progress * 100))
    }
}

fileprivate struct LaunchingLeftTab: View {
    @ObservedObject private var launchState: LaunchState
    @State private var progress: Double = 0
    
    init(launchState: LaunchState) {
        self.launchState = launchState
    }
    
    var body: some View {
        VStack {
            // 进度条
            HStack(spacing: 0) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: ColorConstants.Color4, location: 0),
                                .init(color: ColorConstants.Color3, location: 0.6)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progress * 260)
                Rectangle()
                    .fill(ColorConstants.Color6)
                    .frame(width: (1 - progress) * 260)
            }
            .frame(width: 260, height: 4)
            .padding(.bottom, 27)
            
            VStack(alignment: .leading, spacing: 5) {
                LaunchingInfoRow(label: "当前步骤", value: launchState.stage.rawValue)
                if let account = launchState.options.account {
                    LaunchingInfoRow(label: "验证方式", value: account.authMethodName)
                }
                if progress < 1.0 {
                    LaunchingInfoRow(label: "启动进度", value: "", modifier: ProgressModifier(progress: progress))
                }
            }
        }
        .onAppear {
            DataManager.shared.leftTabId = .init()
        }
        .onChange(of: launchState.progress) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                self.progress = newValue
            }
        }
        .onChange(of: launchState.stage) { stage in
            if stage == .finish {
                DataManager.shared.objectWillChange.send()
            }
        }
    }
    
    private struct LaunchingInfoRow<M: ViewModifier>: View {
        private let label: String
        private let value: String
        private let modifier: M
        
        init(label: String, value: String, modifier: M = EmptyModifier()) {
            self.label = label
            self.value = value
            self.modifier = modifier
        }
        
        var body: some View {
            HStack {
                Text(label)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(Color("TextColor"))
                    .opacity(0.5)
                Text(value)
                    .modifier(modifier)
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(Color("TextColor"))
            }
        }
    }
}

fileprivate struct LeftTab: View {
    @ObservedObject private var dataManager: DataManager = .shared
    @ObservedObject private var accountManager: AccountManager = .shared
    @State private var instance: MinecraftInstance?
    
    private var accountView: some View {
        MyListItem {
            VStack {
                if let account = accountManager.getAccount() {
                    MinecraftAvatar(account: account, src: account.uuid.uuidString)
                    Text(account.name)
                        .font(.custom("PCL English", size: 16))
                        .foregroundStyle(Color("TextColor"))
                } else {
                    Image("Missingno")
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 58)
                        .padding(6)
                    Text("无账号")
                        .font(.custom("PCL English", size: 16))
                        .foregroundStyle(Color("TextColor"))
                }
                Text("点击头像进入账号管理")
                    .font(.custom("PCL English", size: 10))
                    .foregroundStyle(Color(hex: 0x8C8C8C))
                    .padding(.top, 2)
            }
            .padding(4)
        }
        .onTapGesture {
            dataManager.router.append(.accountManagement)
        }
    }
    
    private var launchButtons: some View {
        Group {
            if let instance = self.instance {
                MyButton(text: "启动游戏", descriptionText: instance.name, foregroundStyle: AppSettings.shared.theme.getTextStyle()) {
                    if dataManager.launchState != nil { return }
                    let launchOptions: LaunchOptions = .init()
                    let launchState: LaunchState = .init(options: launchOptions)
                    dataManager.launchState = launchState
                    
                    Task {
                        guard await launchPrecheck(launchOptions) else {
                            dataManager.launchState = nil
                            return
                        }
                        debug("正在启动游戏")
                        await instance.launch(launchOptions, launchState)
                        await MainActor.run {
                            dataManager.launchState = nil
                        }
                    }
                }
                .frame(height: 55)
                .padding()
                .padding(.bottom, -27)
            } else {
                MyButton(text: "下载游戏", descriptionText: "未找到可用的游戏实例") {
                    dataManager.router.setRoot(.download)
                }
                .frame(height: 55)
                .padding()
                .padding(.bottom, -27)
            }
            HStack(spacing: 12) {
                MyButton(text: "实例选择") {
                    dataManager.router.append(.instanceSelect)
                }
                if MinecraftDirectoryManager.shared.getDefaultInstance() != nil {
                    MyButton(text: "实例设置") {
                        if let instance = self.instance {
                            dataManager.router.append(.instanceSettings(instance: instance))
                        }
                    }
                }
            }
            .frame(height: 32)
            .padding()
            .padding(.bottom, 4)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let launchState = dataManager.launchState, launchState.stage != .finish {
                LaunchingLeftTab(launchState: launchState)
                Spacer()
            } else {
                accountView
                Spacer()
                launchButtons
            }
        }
        .frame(width: 300)
        .foregroundStyle(Color(hex: 0x343D4A))
        .onAppear {
            if let instance = dataManager.defaultInstance {
                self.instance = instance
            }
        }
    }
    
    private func launchPrecheck(_ launchOptions: LaunchOptions) async -> Bool {
        // MARK: - Java 检查
        if case .failure(let error) = LaunchPrecheck.checkJava(instance!, launchOptions) {
            switch error {
            case .javaNotFound:
                PopupManager.shared.show(.init(.error, "错误", "你还没有安装 Java\n如果你安装过 Java 并且没有在 Java 管理中看到，请点击“手动添加 Java”", [.init(label: "安装 Java", style: .normal), .close])) { button in
                    if button == 0 {
                        dataManager.router.path = [.settings, .javaSettings, .javaDownload]
                    }
                }
                return false
            case .noUsableJava(let minVersion):
                PopupManager.shared.show(.init(.error, "错误", "当前没有满足条件的 Java 版本\n你需要安装 \(minVersion) 及以上版本的 Java！", [.init(label: "安装 Java", style: .normal), .close])) { button in
                    if button == 0 {
                        dataManager.router.path = [.settings, .javaSettings, .javaDownload]
                    }
                }
                return false
            case .javaNotSupport:
                PopupManager.shared.show(.init(.error, "错误", "你安装 / 选择了一个 ARM64 架构的 Java，但你的电脑不支持。\n请进入 设置 > Java 管理，安装 / 选择一个 x64 架构的 Java。", [.init(label: "安装 Java", style: .normal), .close])) { button in
                    if button == 0 {
                        dataManager.router.path = [.settings, .javaSettings, .javaDownload]
                    }
                }
                return false
            case .invalidMemoryConfiguration:
                PopupManager.shared.show(.init(.error, "错误", "无效的内存配置：0MB。\n请在 实例设置 > 设置 中调整游戏内存配置", [.ok]))
            case .rosetta:
                if await PopupManager.shared.showAsync(.init(.normal, "警告", "你安装 / 选择了一个 x64 架构的 Java，需要通过转译运行，这将会损耗大部分性能。\n你可以进入 设置 > Java 管理，安装 / 选择一个 ARM64 架构的 Java。", [.init(label: "继续启动", style: .normal), .close]))
                == 1 {
                    return false
                }
            }
        }
        
        if case .failure(let error) = LaunchPrecheck.checkAccount(instance!, launchOptions) {
            switch error {
            case .missingAccount:
                PopupManager.shared.show(.init(.error, "错误", "请先创建一个账号并选择再启动游戏！", [.ok]))
                return false
            case .noMicrosoftAccount:
                if Locale.current.region?.identifier == "US" {
                    if [750, 880, 950, 1100, 1300, 1500, 1700, 1900].contains(AppSettings.shared.launchCount) {
                        let button = await PopupManager.shared.showAsync(.init(.normal, "考虑一下正版？", "你已经启动了 \(AppSettings.shared.launchCount) 次 Minecraft 啦！\n如果觉得 Minecraft 还不错，可以购买正版支持一下，毕竟开发游戏也真的很不容易……不要一直白嫖啦。\n在登录一次正版账号后，就不会再出现这个提示了！", [.init(label: "支持正版游戏！", style: .normal), .init(label: "下次一定", style: .normal)]))
                        if button == 0 {
                            NSWorkspace.shared.open(URL(string: "https://www.xbox.com/zh-cn/games/store/minecraft-java-bedrock-edition-for-pc/9nxp44l49shj")!)
                            return false
                        }
                    }
                } else {
                    let button = await PopupManager.shared.showAsync(.init(.normal, "正版验证", "你必须先登录正版账号才能启动游戏！", [.init(label: "购买正版", style: .normal), .init(label: "试玩", style: .normal), .init(label: "返回", style: .normal)]))
                    if button == 0 {
                        NSWorkspace.shared.open(URL(string: "https://www.xbox.com/zh-cn/games/store/minecraft-java-bedrock-edition-for-pc/9nxp44l49shj")!)
                        return false
                    } else if button == 1 {
                        launchOptions.isDemo = true
                    }
                }
            }
        }
            
        return true
    }
}

struct LaunchView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    @ObservedObject private var announcementManager: AnnouncementManager = .shared
    
    var body: some View {
        ScrollView {
            if let announcement = announcementManager.lastAnnouncement {
                MyCard(title: "\(announcement.isImportant ? "重要公告" : "公告") | \(announcement.title)") {
                    VStack(alignment: .leading, spacing: 2) {
                        announcement.makeContentView()
                        Text("—— \(announcement.author)，\(DateFormatters.shared.displayDateFormatter.string(from: announcement.time))")
                            .font(.custom("PCL English", size: 14))
                            .foregroundStyle(Color(hex: 0x7F8790))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .padding()
            }
            
            if Metadata.version == "本地构建" {
                StaticMyCard(index: 1, title: "警告") {
                    VStack(spacing: 4) {
                        Text("你正在使用本地构建的 PCL.Mac！")
                        Text("请不要在 GitHub 上反馈本启动器中出现的 Bug！")
                    }
                    .font(.custom("PCL English", size: 14))
                    .foregroundStyle(Color("TextColor"))
                }
                .padding()
            }
            Spacer()
        }
        .scrollIndicators(.never)
        .onAppear {
            dataManager.leftTab(310) {
                LeftTab()
            }
        }
    }
    
    @ViewBuilder
    func logLineView(_ line: String) -> some View {
        let regex = #"\[(INFO|WARN|ERROR|DEBUG)\]"#
        let nsLine = line as NSString
        if let match = try? NSRegularExpression(pattern: regex)
            .firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length)),
           let levelRange = Range(match.range(at: 1), in: line),
           let tagRange = Range(match.range(at: 0), in: line)
        {
            let level = String(line[levelRange])
            let tag = String(line[tagRange])
            let rest = String(line[tagRange.upperBound...])
            let color: Color = {
                switch level {
                    case "INFO": return .green
                    case "WARN": return .yellow
                    case "ERROR": return .red
                    case "DEBUG": return .blue
                    default: return .primary
                }
            }()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(tag)
                    .font(.custom("PCL English", size: 14))
                    .foregroundColor(color)
                Text(rest)
                    .font(.custom("PCL English", size: 14))
            }
        } else {
            HStack {
                Text(line)
                    .font(.custom("PCL English", size: 14))
            }
        }
    }
}
