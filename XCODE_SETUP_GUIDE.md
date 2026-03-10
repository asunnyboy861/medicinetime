# 📱 Xcode 完整配置指南

> **适用版本**: Xcode 15.0+  
> **iOS 版本**: iOS 17.0+  
> **最后更新**: March 10, 2026

---

## 📋 配置清单

### 必须配置（3 项）
- [ ] 1. Apple ID 签名配置
- [ ] 2. iCloud/CloudKit 配置
- [ ] 3. App Groups 配置

### 可选配置（2 项）
- [ ] 4. TestFlight 配置
- [ ] 5. App Store 配置

---

## 🚀 第一步：打开项目

### 1.1 打开 Xcode 项目
```bash
open /Volumes/Untitled/app/20260309/medicinetime/medicinetime.xcodeproj
```

或者：
1. 启动 Xcode
2. 点击 "Open Another Project..."
3. 选择 `/Volumes/Untitled/app/20260309/medicinetime/medicinetime.xcodeproj`

---

## ✍️ 第二步：配置 Apple ID 签名（必须）

### 2.1 添加 Apple ID

1. **打开 Xcode 设置**
   - 菜单栏：`Xcode` → `Settings...` (⌘,)
   - 或点击左下角齿轮图标

2. **添加账户**
   - 点击 "Accounts" 标签
   - 点击左下角 "+" 按钮
   - 选择 "Apple ID"
   - 点击 "Next"

3. **登录**
   - 输入你的 Apple ID（建议使用 Gmail 或 Outlook）
   - 输入密码
   - 完成双重认证（如果启用）

4. **验证**
   - 确保看到你的 Apple ID 出现在列表中
   - 点击 "Manage Certificates..."
   - 确保有 "Apple Development" 证书（蓝色图标）
   - 如果没有，点击 "+" → "Apple Development" 创建

### 2.2 配置项目签名

1. **选择项目**
   - 在左侧项目导航器中，点击最上方的 `medicinetime` 项目（蓝色图标）

2. **选择 TARGETS**
   - 在右侧，选择 `medicinetime` target

3. **Signing & Capabilities**
   - 点击 "Signing & Capabilities" 标签

4. **配置 Team**
   - 在 "Signing" 部分：
     - ✅ 勾选 "Automatically manage signing"
     - Team: 选择你的 Apple ID
     - Bundle Identifier: `com.medcabinet.shared`（应该自动填充）

5. **验证**
   - 确保没有红色或黄色警告
   - 如果看到 "Signing for 'medicinetime' requires a development team"
     - 点击 "Add Account..." 添加 Apple ID

---

## ☁️ 第三步：配置 iCloud/CloudKit（必须）

### 3.1 添加 iCloud Capability

**重要**：此步骤启用 CloudKit 同步和家庭共享功能

1. **打开 Signing & Capabilities**
   - 确保在 `medicinetime` target
   - 点击 "Signing & Capabilities" 标签

2. **添加 iCloud**
   - 点击左上角 "+ Capability" 按钮
   - 搜索 "iCloud"
   - 双击 "iCloud" 添加

3. **配置 iCloud 设置**
   
   在 "iCloud" 部分：
   
   - ✅ 勾选 "CloudKit"
   - ✅ 勾选 "Key-value storage"（可选，用于同步设置）
   
   **iCloud Containers**:
   - 点击 "+" 按钮
   - 选择 "Specify a container..."
   - 输入：`iCloud.com.medcabinet`
   - 点击 "Save"

4. **验证 entitlements 文件**
   
   添加后，Xcode 会自动更新 `medicinetime.entitlements` 文件：
   
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
   "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>com.apple.developer.icloud-container-identifiers</key>
       <array>
           <string>iCloud.com.medcabinet</string>
       </array>
       <key>com.apple.developer.icloud-services</key>
       <array>
           <string>CloudKit</string>
       </array>
   </dict>
   </plist>
   ```

### 3.2 在 CloudKit Dashboard 创建容器

**重要**：此步骤在 Apple 服务器上创建你的数据库

1. **访问 CloudKit Dashboard**
   - 打开浏览器：https://icloud.developer.apple.com/dashboard/
   - 使用你的 Apple ID 登录

2. **选择容器**
   - 点击左上角 "Default Container" 下拉菜单
   - 选择 `iCloud.com.medcabinet`
   - 如果是第一次使用，可能需要等待几分钟

3. **创建数据库结构**
   
   **Public Database**（可选，用于未来共享功能）:
   - 暂时不需要配置
   
   **Private Database**（自动创建）:
   - 当用户第一次保存数据时自动创建

4. **配置 Security**
   - 点击 "Security" 标签
   - 确保：
     - ✅ "Allow user to create record zones" = Enabled
     - ✅ "Allow user to create database" = Enabled

5. **验证**
   - 回到 Xcode
   - 运行应用
   - 添加一个药物
   - 检查 CloudKit Dashboard 是否出现数据

---

## 👨‍👩‍👧‍👦 第四步：配置 App Groups（必须）

### 4.1 添加 App Groups Capability

**重要**：此步骤用于未来扩展（小组件、App Clip 等）

1. **打开 Signing & Capabilities**
   - 确保在 `medicinetime` target
   - 点击 "Signing & Capabilities" 标签

2. **添加 App Groups**
   - 点击 "+ Capability" 按钮
   - 搜索 "App Groups"
   - 双击 "App Groups" 添加

3. **配置 App Groups**
   
   - 点击 "+" 按钮
   - 选择 "Specify a group..."
   - 输入：`group.com.medcabinet.shared`
   - 点击 "OK"

4. **验证 entitlements 文件**
   
   应该看到：
   
   ```xml
   <key>com.apple.security.application-groups</key>
   <array>
       <string>group.com.medcabinet.shared</string>
   </array>
   ```

---

## 📸 第五步：配置相机和照片权限（已完成）

### 5.1 验证 Info.plist

**好消息**：权限配置已经包含在 `Info.plist` 中！

检查以下键值对是否存在：

```xml
<!-- 相机权限 -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required to scan medication barcodes and take photos of your medications.</string>

<!-- 照片库权限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is required to select and save medication photos.</string>

<!-- 通知权限 -->
<key>NSUserNotificationsUsageDescription</key>
<string>Notifications are used to alert you when medications are expiring soon or running low on stock.</string>
```

### 5.2 测试权限

1. **运行应用**
   - 按 ⌘ + R 运行

2. **测试相机**
   - 点击 "+" 添加药物
   - 点击相机图标
   - 系统会弹出权限请求
   - 点击 "Allow"

3. **测试照片库**
   - 点击 "+" 添加药物
   - 点击照片图标
   - 系统会弹出权限请求
   - 点击 "Allow"

---

## 🧪 第六步：测试配置

### 6.1 在模拟器中测试

1. **选择模拟器**
   - 点击工具栏的设备选择器
   - 选择 "iPhone 15 Pro" 或其他

2. **运行应用**
   - 按 ⌘ + R
   - 等待构建完成

3. **测试基本功能**
   - ✅ 添加药物
   - ✅ 拍照
   - ✅ 扫描条码
   - ✅ 查看列表

### 6.2 在真机上测试（推荐）

**重要**：真机测试可以验证相机、通知等功能

1. **连接 iPhone**
   - 使用 USB 线连接 iPhone
   - 信任此电脑（如果提示）

2. **选择设备**
   - 在设备选择器中选择你的 iPhone

3. **配置签名**
   - Xcode 会自动使用你的 Apple ID
   - 如果提示 "Untrusted Developer"
     - 在 iPhone 上：设置 → 通用 → VPN 与设备管理
     - 信任你的开发者证书

4. **运行应用**
   - 按 ⌘ + R
   - 在真机上测试所有功能

---

## ⚙️ 第七步：配置 Build Settings（可选优化）

### 7.1 配置 Deployment Target

1. **打开 Build Settings**
   - 选择 `medicinetime` target
   - 点击 "Build Settings" 标签

2. **搜索 "Deployment Target"**
   - 确保 "iOS Deployment Target" = `17.0`

3. **验证**
   - 这确保应用支持 iOS 17.0+ 设备

### 7.2 配置 Swift Version

1. **搜索 "Swift Version"**
   - 确保 "Swift Compiler - Language" → "Swift Language Version" = `Swift 5`

### 7.3 配置 Optimization

1. **搜索 "Optimization"**
   - Debug: `-Onone` (快速编译)
   - Release: `-O` (优化性能)

### 7.4 配置 App Icon

1. **打开 Assets.xcassets**
   - 在左侧导航器，展开 `Assets.xcassets`

2. **选择 AppIcon**
   - 点击 "AppIcon"

3. **拖拽图标**
   - 准备 1024x1024 PNG 图标
   - 拖拽到对应位置

---

## 🚨 常见问题解决

### 问题 1: "No signing certificate found"

**解决方案**:
1. Xcode → Settings → Accounts
2. 选择你的 Apple ID
3. 点击 "Manage Certificates..."
4. 点击 "+" → "Apple Development"
5. 重启 Xcode

### 问题 2: "CloudKit container not found"

**解决方案**:
1. 访问 https://icloud.developer.apple.com/
2. 登录你的 Apple ID
3. 创建容器 `iCloud.com.medcabinet`
4. 等待 5 分钟同步
5. 重新运行应用

### 问题 3: "App Groups configuration mismatch"

**解决方案**:
1. 删除 App Groups capability
2. 重新添加
3. 确保 group ID 完全匹配：`group.com.medcabinet.shared`

### 问题 4: 真机运行失败

**解决方案**:
1. 在 iPhone 上：设置 → 通用 → VPN 与设备管理
2. 找到你的开发者证书
3. 点击 "信任"
4. 重新运行应用

### 问题 5: 相机/照片权限不弹出

**解决方案**:
1. 在 iPhone 上：设置 → 隐私与安全性 → 相机
2. 找到你的应用
3. 开启权限
4. 如果应用不在列表中，卸载重装

---

## ✅ 配置验证清单

完成所有配置后，检查以下项目：

### 签名配置
- [ ] ✅ Apple ID 已添加
- [ ] ✅ Development Certificate 已创建
- [ ] ✅ Bundle ID 正确：`com.medcabinet.shared`
- [ ] ✅ Team 已选择
- [ ] ✅ 无签名警告

### iCloud/CloudKit
- [ ] ✅ iCloud capability 已添加
- [ ] ✅ CloudKit 已勾选
- [ ] ✅ Container: `iCloud.com.medcabinet`
- [ ] ✅ entitlements 文件已更新
- [ ] ✅ CloudKit Dashboard 可访问

### App Groups
- [ ] ✅ App Groups capability 已添加
- [ ] ✅ Group: `group.com.medcabinet.shared`
- [ ] ✅ entitlements 文件已更新

### 权限配置
- [ ] ✅ Info.plist 包含相机权限
- [ ] ✅ Info.plist 包含照片库权限
- [ ] ✅ Info.plist 包含通知权限

### 功能测试
- [ ] ✅ 模拟器运行成功
- [ ] ✅ 真机运行成功（可选）
- [ ] ✅ 可以添加药物
- [ ] ✅ 可以拍照
- [ ] ✅ 可以扫描条码
- [ ] ✅ 通知正常工作

---

## 📊 配置完成后的 entitlements 文件

最终的 `medicinetime.entitlements` 应该如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- App Groups -->
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.medcabinet.shared</string>
	</array>
	
	<!-- iCloud/CloudKit -->
	<key>com.apple.developer.icloud-container-identifiers</key>
	<array>
		<string>iCloud.com.medcabinet</string>
	</array>
	<key>com.apple.developer.icloud-services</key>
	<array>
		<string>CloudKit</string>
	</array>
	<key>com.apple.developer.ubiquity-container-identifiers</key>
	<array>
		<string>iCloud.com.medcabinet</string>
	</array>
</dict>
</plist>
```

---

## 🎯 下一步

配置完成后：

1. **运行应用**
   ```bash
   cd /Volumes/Untitled/app/20260309/medicinetime
   open medicinetime.xcodeproj
   ```

2. **测试功能**
   - 添加 3-5 个药物
   - 测试搜索
   - 测试通知
   - 测试拍照

3. **准备发布**（可选）
   - 查看 `TESTFLIGHT_GUIDE.md`
   - 准备 App Store 截图
   - 编写应用描述

---

## 📞 需要帮助？

如果遇到问题：

1. **查看错误日志**
   - Xcode → View → Navigators → Show Report Navigator (⌘9)
   - 查看最新的 Build Log

2. **清理构建缓存**
   - Product → Clean Build Folder (⇧⌘K)
   - 重新运行

3. **重启 Xcode**
   - 有时重启能解决奇怪的问题

4. **检查 Apple 开发者状态**
   - https://developer.apple.com/system-status/

---

**祝你配置顺利！🎉**

配置完成后，你的应用就准备好在真机上测试和发布到 App Store 了！
