# 🚀 MedCabinet - Quick Start Guide

## ⚡ 5 分钟快速启动

### 步骤 1: 打开项目 (30 秒)
```bash
# 在终端中执行
cd /Volumes/Untitled/app/20260309/medicinetime/medicinetime
open medicinetime.xcodeproj
```

或者在 Xcode 中：
- 打开 Xcode
- File → Open
- 选择 `/Volumes/Untitled/app/20260309/medicinetime/medicinetime.xcodeproj`

### 步骤 2: 配置签名 (1 分钟)
1. 在 Xcode 中选择项目导航器中的 `medicinetime` 项目
2. 选择 `medicinetime` Target
3. 点击 **Signing & Capabilities** 标签
4. 在 **Team** 下拉菜单中选择你的 Apple ID（如果没有，点击 "Add an Account..."）
5. 确保 **Automatically manage signing** 已勾选
6. Bundle Identifier 应该是 `com.medcabinet.app`

### 步骤 3: 选择运行目标 (30 秒)
1. 在 Xcode 顶部工具栏中，点击设备选择器
2. 选择：
   - **iPhone 15 Pro** (推荐用于测试)
   - **iPhone 15** 
   - 或连接你的真实 iPhone

### 步骤 4: 构建并运行 (2-3 分钟)
- 点击 Xcode 左上角的 **Run** 按钮 (▶️)
- 或使用快捷键 **⌘ + R**

**第一次构建可能需要 2-3 分钟**，Xcode 会：
- 索引项目
- 编译 Swift 文件
- 链接框架
- 安装到模拟器/设备

### 步骤 5: 测试应用 (1 分钟)
应用启动后，你应该看到：
1. ✅ **Dashboard** 显示统计卡片（Total, Expiring, Low Stock）
2. ✅ **底部 Tab 栏** 有 4 个标签：Dashboard, Medications, Categories, Settings
3. ✅ **右上角** 有 "+" 添加按钮

#### 测试添加药物：
1. 点击右上角的 **+** 按钮
2. 输入药物名称（例如："Tylenol"）
3. 选择类别（例如："Pain Relief"）
4. 设置数量（例如：30 tablets）
5. 设置过期日期（选择未来日期）
6. 点击 **Save**

#### 测试通知权限：
添加第一个药物后，系统会请求通知权限：
- 点击 **Allow** 以接收过期提醒

---

## 🔍 验证清单

### ✅ 应用应该正常运行的标志：
- [ ] 应用成功启动，无崩溃
- [ ] Dashboard 显示统计卡片
- [ ] 可以点击 "+" 添加药物
- [ ] 添加的药物显示在 Medications 列表中
- [ ] 可以搜索药物
- [ ] 可以按类别过滤
- [ ] 可以点击药物查看详情
- [ ] 可以编辑和删除药物

### ❌ 如果遇到问题：

#### 问题 1: "No such module 'CoreData'"
**解决方案**：
1. 检查项目设置 → General → Frameworks, Libraries, and Embedded Content
2. 如果 CoreData.framework 缺失，点击 "+" 添加它

#### 问题 2: 签名错误
**解决方案**：
1. Xcode → Preferences → Accounts
2. 选择你的 Apple ID
3. 点击 "Manage Certificates"
4. 点击 "+" 添加 iOS Distribution 证书
5. 重新构建项目

#### 问题 3: 构建失败，显示 "Command Swift failed with a nonzero exit code"
**解决方案**：
```bash
# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData

# 重启 Xcode
killall Xcode

# 重新打开项目
open /Volumes/Untitled/app/20260309/medicinetime/medicinetime.xcodeproj
```

#### 问题 4: 模拟器无法启动
**解决方案**：
1. 在模拟器中：Device → Erase All Content and Settings
2. 或创建新的模拟器：Xcode → Window → Devices and Simulators → +

---

## 📱 在真机上测试

### 步骤：
1. 用 USB 线连接你的 iPhone
2. 在 Xcode 设备选择器中选择你的 iPhone
3. 点击 Run (⌘ + R)
4. 在 iPhone 上信任开发者证书：
   - Settings → General → VPN & Device Management
   - 信任你的开发者证书

### 测试通知（真机）：
1. 添加药物后，通知权限请求会自动弹出
2. 如果错过，可以手动开启：
   - Settings → MedCabinet → Notifications → Allow

---

## 🎯 下一步（运行成功后）

### 立即可以做的：
1. ✅ **测试所有功能**
   - 添加 5-10 个药物
   - 测试搜索
   - 测试类别过滤
   - 测试编辑和删除
   - 测试相机拍照

2. ✅ **查看代码结构**
   - 打开 `Views/ContentView.swift` 查看主界面
   - 打开 `ViewModels/MedicationViewModel.swift` 查看业务逻辑
   - 打开 `CoreData/PersistenceController.swift` 查看数据层

3. ✅ **阅读文档**
   - `README.md` - 项目概览
   - `BUILD_GUIDE.md` - 详细构建指南
   - `TESTING_STANDARDS.md` - 测试标准

### 接下来要实现的功能：

#### 高优先级（本周）：
1. **CloudKit 同步**
   - 在 Apple Developer Portal 创建 CloudKit 容器
   - 更新 `medicinetime.entitlements`
   - 实现同步逻辑

2. **家庭共享**
   - 实现邀请系统
   - 添加家庭成员管理 UI
   - 测试隐私模式

3. **导出功能**
   - PDF 导出（使用 PDFKit）
   - CSV 导出
   - 分享功能

#### 中优先级（下周）：
4. **条码数据库集成**
   - OpenFDA API 集成
   - UPC Database API
   - 本地缓存

5. **统计图表**
   - 使用 Swift Charts
   - 月度使用图表
   - 类别饼图

6. **主屏幕小组件**
   - WidgetKit 扩展
   - 即将过期小组件
   - 快速添加小组件

---

## 🛠️ 开发提示

### 有用的快捷键：
- **⌘ + B**: 构建项目
- **⌘ + R**: 运行项目
- **⌘ + U**: 运行测试
- **⇧ + ⌘ + K**: 清理构建文件夹
- **⌘ + ,**: 打开项目设置
- **⌘ + 1**: 显示/隐藏项目导航器
- **⌘ + 0**: 打开/关闭导航器面板

### 调试技巧：
1. **查看控制台日志**：
   - Xcode → View → Debug Area → Activate Console
   - 或点击底部的小三角图标

2. **断点调试**：
   - 在代码行号处点击添加断点
   - 运行到断点处会暂停
   - 使用调试工具栏单步执行

3. **查看 Core Data 数据**：
   ```swift
   // 在代码中添加：
   print("Medications: \(viewModel.medications.count)")
   ```

### 性能分析：
1. **Instruments 工具**：
   - Product → Profile
   - 选择 Time Profiler 检查性能
   - 选择 Allocations 检查内存

2. **内存警告测试**：
   - 在模拟器中：Debug → Trigger Memory Warning
   - 观察应用是否正确处理

---

## 📚 学习资源

### SwiftUI 官方文档：
- [Apple SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

### Core Data:
- [Core Data Documentation](https://developer.apple.com/documentation/coredata)
- [Core Data Tutorials](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)

### CloudKit:
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [CloudKit Basics](https://developer.apple.com/videos/play/wwdc2014/231/)

### 本项目代码参考：
- `Med-Tracker` - SwiftUI + Core Data 基础架构
- `Pain-Meds-Buddy-Public` - CloudKit + 通知系统
- `MedKeeper` - 数据模型设计参考

---

## 🎉 恭喜！

你现在已经成功运行了 MedCabinet 应用！

### 你已经完成：
- ✅ 项目配置和签名
- ✅ 在模拟器/真机上运行
- ✅ 测试了核心功能
- ✅ 了解了项目结构

### 接下来：
1. 深入阅读代码
2. 实现 CloudKit 同步
3. 添加导出功能
4. 准备 TestFlight 测试
5. 提交 App Store

**祝你开发顺利！🚀**

---

## 📞 需要帮助？

### 检查这些文件：
- `README.md` - 项目结构和功能说明
- `BUILD_GUIDE.md` - 详细构建指南和故障排除
- `TESTING_STANDARDS.md` - 测试标准和验收标准
- `us.md` - 完整英文操作指南

### 常见问题：
查看 `BUILD_GUIDE.md` 的 "Troubleshooting" 部分

### 代码问题：
查看各个 Swift 文件中的注释

---

*Last updated: March 10, 2026*
*MedCabinet v1.0.0*
