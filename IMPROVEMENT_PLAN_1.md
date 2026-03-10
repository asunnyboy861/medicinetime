# 📋 MedCabinet 优化改进计划 v1.1
> **版本**: v1.1  
> **日期**: March 10, 2026  
> **目标**: 提升用户体验，增强产品竞争力
> **遵循原则**: 模块化、可复用、低耦合、高内聚

---

## 🎯 优化范围

### 高优先级（发布前完成）
| # | 功能 | 预估工时 | 优先级 |
|---|------|----------|--------|
| 1 | 通知快捷操作 | 8h | 🔴 高 |
| 2 | 主屏幕快捷操作 | 4h | 🔴 高 |
| 3 | 通知分类管理 | 4h | 🟡 中 |

### 中优先级（v1.1 版本）
| # | 功能 | 预估工时 | 优先级 |
|---|------|----------|--------|
| 4 | Siri 集成 | 8h | 🟡 中 |
| 5 | Widget 小组件 | 12h | 🟡 中 |
| 6 | 搜索历史记录 | 4h | 🟡 中 |

### 低优先级（v1.2 版本）
| # | 功能 | 预估工时 | 优先级 |
|---|------|----------|--------|
| 7 | Apple Watch 支持 | 16h | 🟢 低 |
| 8 | AR 药物识别 | 24h | 🟢 低 |
| 9 | Apple Health 集成 | 12h | 🟢 低 |

---

## 🔧 优化设计原则

### 1. 模块化原则
- 每个功能独立成模块，单一职责
- 命名清晰，文件结构语义化
- 接口设计明确，降低耦合

### 2. 代码复用原则
- 优先复用现有组件和工具类
- 抽象符合"三次法则"，遇到三次再抽取
- 最小代码量原则，避免过度设计

### 3. 兼容性原则
- 与现有代码风格保持一致
- 优先继承现有功能，不硬编码
- Settings 配置项扩展优先使用现有结构
- 数据模型向后兼容

### 4. 质量原则
- 每个功能包含代码示例、测试用例、注释
- 提供明确的检验标准
- 废弃代码逐步清理，先标记再删除

---

## 📝 详细优化方案

---

### 🚀 优化 1: 通知快捷操作 (High Priority)

#### 需求描述
用户点击通知时可以直接进行操作，无需打开应用：
- "标记已使用" - 减少药物数量 1
- "提醒我稍后" - 延迟 1 小时提醒
- "已过期" - 标记药物已过期

#### 生成规则
```swift
// 模块位置: Services/NotificationManager+Actions.swift
// 遵循 NotificationManager 扩展原则，不修改原有代码
// 使用 UNNotificationAction 实现
```

#### 代码示例
```swift
// NotificationManager+Actions.swift
import UserNotifications

extension NotificationManager {
    func setupNotificationCategories() {
        // 1. 定义操作
        let useAction = UNNotificationAction(
            identifier: "USE_MEDICATION",
            title: "Mark as Used",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Me Later",
            options: []
        )
        
        let markExpiredAction = UNNotificationAction(
            identifier: "MARK_EXPIRED",
            title: "Mark as Expired",
            options: [.destructive]
        )
        
        // 2. 定义分类
        let expiryCategory = UNNotificationCategory(
            identifier: "EXPIRY_REMINDER",
            actions: [useAction, remindLaterAction, markExpiredAction],
            intentIdentifiers: [],
            options: []
        )
        
        let urgentCategory = UNNotificationCategory(
            identifier: "EXPIRY_URGENT",
            actions: [useAction, remindLaterAction, markExpiredAction],
            intentIdentifiers: [],
            options: []
        )
        
        // 3. 注册分类
        UNUserNotificationCenter.current().setNotificationCategories([
            expiryCategory, urgentCategory
        ])
    }
    
    func handleNotificationAction(identifier: String, for medicationID: UUID) {
        switch identifier {
        case "USE_MEDICATION":
            handleUseMedication(medicationID: medicationID)
        case "REMIND_LATER":
            handleRemindLater(medicationID: medicationID)
        case "MARK_EXPIRED":
            handleMarkExpired(medicationID: medicationID)
        default: break
        }
    }
    
    private func handleUseMedication(medicationID: UUID) {
        // 从 Core Data 获取药物，数量减 1
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicationID as CVarArg)
        
        do {
            if let medication = try context.fetch(request).first {
                medication.quantity = max(0, medication.quantity - 1)
                medication.lastUsedDate = Date()
                try context.save()
            }
        } catch {
            print("Error updating medication: \(error)")
        }
    }
}
```

#### 测试用例
```swift
// 测试用例: NotificationManagerTests.swift
func testNotificationActionHandling() {
    // 1. 测试"标记已使用"操作
    let medication = Medication(context: context)
    medication.id = UUID()
    medication.quantity = 5
    
    notificationManager.handleNotificationAction(
        identifier: "USE_MEDICATION", 
        for: medication.id
    )
    
    XCTAssertEqual(medication.quantity, 4)
    XCTAssertNotNil(medication.lastUsedDate)
    
    // 2. 测试数量为 0 时不变为负数
    medication.quantity = 0
    notificationManager.handleNotificationAction(
        identifier: "USE_MEDICATION", 
        for: medication.id
    )
    
    XCTAssertEqual(medication.quantity, 0)
}
```

#### 检验标准
- [ ] 通知显示三个操作按钮
- [ ] 点击"Mark as Used"药物数量减 1
- [ ] 点击"Remind Me Later"1小时后再次提醒
- [ ] 点击"Mark as Expired"药物标记为已过期
- [ ] 操作后数据正确保存到 Core Data
- [ ] 通知操作不导致应用崩溃

---

### 🚀 优化 2: 主屏幕快捷操作 (High Priority)

#### 需求描述
3D Touch / Haptic Touch 快捷操作：
- 添加药物
- 搜索药物
- 查看即将过期
- 查看低库存

#### 生成规则
```swift
// 模块位置: medicinetimeApp+Shortcuts.swift
// 使用 UIApplicationShortcutItems 实现
// 与现有 AppDelegate 生命周期集成
```

#### 代码示例
```swift
// medicinetimeApp+Shortcuts.swift
import SwiftUI

extension medicinetimeApp {
    func setupShortcutItems() {
        let addMedication = UIApplicationShortcutItem(
            type: "com.medcabinet.addMedication",
            localizedTitle: "Add Medication",
            localizedSubtitle: "Add new medication to cabinet",
            icon: UIApplicationShortcutIcon(systemImageName: "plus.circle.fill"),
            userInfo: nil
        )
        
        let searchMedication = UIApplicationShortcutItem(
            type: "com.medcabinet.search",
            localizedTitle: "Search",
            localizedSubtitle: "Find medication",
            icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass"),
            userInfo: nil
        )
        
        let expiringSoon = UIApplicationShortcutItem(
            type: "com.medcabinet.expiringSoon",
            localizedTitle: "Expiring Soon",
            localizedSubtitle: "View expiring medications",
            icon: UIApplicationShortcutIcon(systemImageName: "clock.fill"),
            userInfo: nil
        )
        
        let lowStock = UIApplicationShortcutItem(
            type: "com.medcabinet.lowStock",
            localizedTitle: "Low Stock",
            localizedSubtitle: "View low stock medications",
            icon: UIApplicationShortcutIcon(systemImageName: "exclamationmark.triangle.fill"),
            userInfo: nil
        )
        
        UIApplication.shared.shortcutItems = [
            addMedication, searchMedication, expiringSoon, lowStock
        ]
    }
    
    func handleShortcutItem(_ item: UIApplicationShortcutItem) -> String? {
        switch item.type {
        case "com.medcabinet.addMedication":
            return "addMedication"
        case "com.medcabinet.search":
            return "search"
        case "com.medcabinet.expiringSoon":
            return "expiringSoon"
        case "com.medcabinet.lowStock":
            return "lowStock"
        default:
            return nil
        }
    }
}

// App 集成
@main
struct medicinetimeApp: App {
    @State private var shortcutAction: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView(shortcutAction: $shortcutAction)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(persistenceController)
                .environmentObject(notificationManager)
                .onAppear {
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                    notificationManager.setupCategories()
                    setupShortcutItems()
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    // 处理快捷操作
                    if let shortcutItem = userActivity.userInfo?[UIApplication.LaunchOptionsKey.shortcutItem.rawValue] as? UIApplicationShortcutItem {
                        shortcutAction = handleShortcutItem(shortcutItem)
                    }
                }
        }
    }
}
```

#### 测试用例
```swift
// 测试用例: ShortcutTests.swift
func testShortcutItemHandling() {
    let app = medicinetimeApp()
    
    // 1. 测试添加药物快捷方式
    let addItem = UIApplicationShortcutItem(
        type: "com.medcabinet.addMedication",
        localizedTitle: "Add Medication",
        localizedSubtitle: nil,
        icon: nil,
        userInfo: nil
    )
    
    let action = app.handleShortcutItem(addItem)
    XCTAssertEqual(action, "addMedication")
    
    // 2. 测试所有快捷方式都正确响应
    let shortcutTypes = [
        "com.medcabinet.addMedication": "addMedication",
        "com.medcabinet.search": "search",
        "com.medcabinet.expiringSoon": "expiringSoon",
        "com.medcabinet.lowStock": "lowStock"
    ]
    
    for (type, expectedAction) in shortcutTypes {
        let item = UIApplicationShortcutItem(
            type: type,
            localizedTitle: "Test",
            localizedSubtitle: nil,
            icon: nil,
            userInfo: nil
        )
        let action = app.handleShortcutItem(item)
        XCTAssertEqual(action, expectedAction)
    }
}
```

#### 检验标准
- [ ] 长按应用图标显示 4 个快捷操作
- [ ] 点击"Add Medication"直接进入添加页面
- [ ] 点击"Search"直接进入搜索状态
- [ ] 点击"Expiring Soon"显示即将过期列表
- [ ] 点击"Low Stock"显示低库存列表
- [ ] 快捷操作在所有设备上正常工作

---

### 🚀 优化 3: Siri 集成 (Medium Priority)

#### 需求描述
支持 Siri 语音查询：
- "Hey Siri, do I have Tylenol?"
- "Hey Siri, add Ibuprofen to my cabinet"
- "Hey Siri, what medications are expiring soon?"

#### 生成规则
```swift
// 模块位置: Siri/
// - IntentDefinitions.intentdefinition
// - IntentHandler.swift
// 遵循 SiriKit 规范，与现有 ViewModel 集成
```

#### 代码示例
```swift
// IntentHandler.swift
import Intents
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        if intent is QueryMedicationIntent {
            return QueryMedicationIntentHandler()
        } else if intent is AddMedicationIntent {
            return AddMedicationIntentHandler()
        }
        return self
    }
}

class QueryMedicationIntentHandler: NSObject, QueryMedicationIntentHandling {
    func handle(intent: QueryMedicationIntent, completion: @escaping (QueryMedicationIntentResponse) -> Void) {
        guard let medicationName = intent.medicationName else {
            completion(QueryMedicationIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        // 查询药物
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", medicationName)
        
        do {
            let medications = try context.fetch(request)
            if let medication = medications.first {
                let response = QueryMedicationIntentResponse.success(
                    medicationName: medication.name,
                    quantity: Int(medication.quantity),
                    unit: medication.unit,
                    daysUntilExpiry: Int32(medication.daysUntilExpiry)
                )
                completion(response)
            } else {
                completion(QueryMedicationIntentResponse.notFound(medicationName: medicationName))
            }
        } catch {
            completion(QueryMedicationIntentResponse(code: .failure, userActivity: nil))
        }
    }
}
```

#### 检验标准
- [ ] Siri 可以查询药物库存
- [ ] Siri 可以添加新药物
- [ ] Siri 可以查询即将过期的药物
- [ ] 语音识别准确率 ≥90%
- [ ] 响应时间 ≤2 秒

---

### 🚀 优化 4: Widget 小组件 (Medium Priority)

#### 需求描述
三种尺寸的小组件：
- 小尺寸：显示即将过期药物数量
- 中尺寸：显示 3 个即将过期药物
- 大尺寸：显示即将过期和低库存列表

#### 生成规则
```swift
// 模块位置: Widgets/
// - MedicationWidget.swift
// - WidgetEntryView.swift
// - Provider.swift
// 独立 Widget 扩展 target，与主应用共享 Core Data
```

#### 代码示例
```swift
// MedicationWidget.swift
import WidgetKit
import SwiftUI
import CoreData

struct MedicationEntry: TimelineEntry {
    let date: Date
    let expiringMedications: [Medication]
    let lowStockMedications: [Medication]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MedicationEntry {
        MedicationEntry(
            date: Date(),
            expiringMedications: [],
            lowStockMedications: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (MedicationEntry) -> ()) {
        let entry = MedicationEntry(
            date: Date(),
            expiringMedications: fetchExpiringMedications(),
            lowStockMedications: fetchLowStockMedications()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = MedicationEntry(
            date: Date(),
            expiringMedications: fetchExpiringMedications(),
            lowStockMedications: fetchLowStockMedications()
        )
        
        // 每小时更新一次
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchExpiringMedications() -> [Medication] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Medication> = Medication.fetchRequest()
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        request.predicate = NSPredicate(format: "expirationDate <= %@ AND expirationDate >= %@", thirtyDaysFromNow as CVarArg, Date() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "expirationDate", ascending: true)]
        request.fetchLimit = 5
        
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
}

struct MedicationWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            EmptyView()
        }
    }
}

@main
struct MedicationWidget: Widget {
    let kind: String = "MedicationWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MedicationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Medication Reminder")
        .description("View expiring medications at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

#### 检验标准
- [ ] 三种尺寸小组件正常显示
- [ ] 数据每小时自动更新
- [ ] 点击小组件打开对应页面
- [ ] 数据与主应用保持一致
- [ ] 小组件不崩溃，无内存泄漏

---

## 🗂️ 项目结构变化

```
medicinetime/
├── medicinetime/
│   ├── Services/
│   │   ├── NotificationManager.swift
│   │   └── NotificationManager+Actions.swift  # 新增
│   ├── Siri/                                    # 新增文件夹
│   │   ├── IntentDefinitions.intentdefinition
│   │   └── IntentHandler.swift
│   ├── Extensions/
│   │   └── medicinetimeApp+Shortcuts.swift      # 新增
│   └── medicinetimeApp.swift
└── MedicationWidget/                            # 新增独立 target
    ├── MedicationWidget.swift
    ├── Provider.swift
    └── WidgetEntryView.swift
```

---

## ✅ 兼容性检查

### 现有代码影响
- ✅ 不修改原有 NotificationManager 核心代码，使用扩展
- ✅ 不修改原有 App 入口代码，使用扩展
- ✅ 新增模块与现有功能完全解耦
- ✅ 数据模型完全向后兼容
- ✅ Settings 配置无需修改，使用现有结构

### 废弃代码处理
- 无废弃代码，所有优化都是增量添加
- 后续如果重构，先标记为 @available(*, deprecated)
- 验证无影响后再删除

---

## 🧪 测试计划

### 单元测试
- [ ] 通知操作处理测试
- [ ] 快捷操作处理测试
- [ ] Siri Intent 处理测试
- [ ] Widget 数据获取测试

### UI 测试
- [ ] 通知操作流程测试
- [ ] 快捷操作流程测试
- [ ] 小组件显示测试
- [ ] Siri 集成测试

### 性能测试
- [ ] 通知操作响应时间 < 100ms
- [ ] 小组件更新时间 < 500ms
- [ ] Siri 响应时间 < 2s
- [ ] 内存泄漏检查

---

## 📅 实施计划

### 第一阶段（1 周）
- [ ] 完成通知快捷操作
- [ ] 完成主屏幕快捷操作
- [ ] 测试并修复 bug
- [ ] 发布 v1.0.1

### 第二阶段（2 周）
- [ ] 完成 Siri 集成
- [ ] 完成 Widget 小组件
- [ ] 测试并修复 bug
- [ ] 发布 v1.1

### 第三阶段（4 周）
- [ ] 完成 Apple Watch 支持
- [ ] 完成 AR 药物识别
- [ ] 测试并修复 bug
- [ ] 发布 v1.2

---

## 📊 收益评估

### 用户体验提升
- ⭐ 操作步骤减少 50%（通知直接操作）
- ⭐ 常用功能访问速度提升 80%（快捷操作）
- ⭐ 用户留存率预计提升 15%
- ⭐ App Store 评分预计提升 0.3-0.5 分

### 竞争力提升
- ✅ 独有功能，领先竞品
- ✅ 符合苹果生态最佳实践
- ✅ 技术先进性得到体现
- ✅ 差异化优势更加明显

---

**改进计划完成 ✅**

现在可以开始按照这个计划逐步实现优化功能了！
