# 📂 MedCabinet - Complete Project Structure

## 🗂️ File System Overview

```
medicinetime/
│
├── 📱 medicinetime/                      # Main App Source Code
│   │
│   ├── medicinetimeApp.swift             # ⭐ App Entry Point
│   │   └── Main app with dependency injection
│   │
│   ├── CoreData/                         # 💾 Data Layer
│   │   ├── PersistenceController.swift   # Core Data Stack + CloudKit
│   │   ├── Medication+CoreDataClass.swift
│   │   ├── FamilyMember+CoreDataClass.swift
│   │   ├── MedicationUsage+CoreDataClass.swift
│   │   ├── Category+CoreDataClass.swift
│   │   └── MedCabinet.xcdatamodel.xml    # Data Model (XML representation)
│   │
│   ├── ViewModels/                       # 🧠 Business Logic
│   │   └── MedicationViewModel.swift     # Main ViewModel (CRUD + Filtering)
│   │
│   ├── Views/                            # 🎨 UI Layer
│   │   ├── ContentView.swift             # 🏠 Dashboard & TabView
│   │   ├── MedicationListView.swift      # 📋 List with Search/Filter
│   │   ├── MedicationDetailView.swift    # 🔍 Detail View
│   │   ├── AddMedicationView.swift       # ➕ Add Form
│   │   ├── EditMedicationView.swift      # ✏️ Edit Form
│   │   ├── CategoriesView.swift          # 📁 Categories Management
│   │   ├── SettingsView.swift            # ⚙️ Settings
│   │   ├── BarcodeScannerView.swift      # 📷 Barcode Scanner (AVFoundation)
│   │   ├── ImagePicker.swift             # 📸 Camera/Photo Library
│   │   └── Components/
│   │       └── MedicationCard.swift      # 🃏 Reusable Card Component
│   │
│   ├── Services/                         # 🔔 Background Services
│   │   └── NotificationManager.swift     # Notification Scheduling
│   │
│   ├── Extensions/                       # 🔧 Utilities
│   │   ├── Color+Hex.swift               # Color Utilities + App Colors
│   │   └── Extensions.swift              # Date, String, Array, Int extensions
│   │
│   ├── Info.plist                        # 📋 App Configuration
│   └── medicinetime.entitlements         # 🔐 CloudKit + App Groups
│
├── 🧪 medicinetimeTests/                 # Unit Tests
│   └── medicinetimeTests.swift
│
├── 📱 medicinetimeUITests/               # UI Tests
│   ├── medicinetimeUITests.swift
│   └── medicinetimeUITestsLaunchTests.swift
│
├── 📚 Documentation/                     # 📖 Documentation Files
│   ├── README.md                         # Project Overview
│   ├── BUILD_GUIDE.md                    # Build & Compilation Guide
│   ├── TESTING_STANDARDS.md              # Testing Standards & UI Criteria
│   ├── PROJECT_COMPLETION_SUMMARY.md     # Completion Summary
│   └── QUICK_START.md                    # 5-Minute Quick Start
│
├── 📋 Configuration Files
│   ├── us.md                             # 🇺🇸 English Operation Guide (Main Spec)
│   ├── 2026-03-09 药物库存追踪（美国）操作指南.md  # 🇨🇳 Original Chinese Guide
│   ├── ARCHITECTURE_DEEP_ANALYSIS.md     # Architecture Analysis
│   └── US_MD_SUPPLEMENTS_SUMMARY.md      # Supplement Documentation
│
└── 🗑️ Cloned GitHub Projects (Reference)
    ├── Med-Tracker/                      # SwiftUI + Core Data (80% reusable)
    ├── Pain-Meds-Buddy-Public/           # SwiftUI + CoreData + CloudKit (85% reusable)
    ├── MedKeeper/                        # Swift (UIKit) (60% reusable)
    └── medicine-cabinet/                 # React + FastAPI + SQLite (40% reusable)
```

---

## 📊 File Statistics

### Source Code Files (24 files)

| Category | Count | Files |
|----------|-------|-------|
| **Core Data** | 5 | PersistenceController, Medication, FamilyMember, MedicationUsage, Category |
| **ViewModels** | 1 | MedicationViewModel |
| **Views** | 10 | ContentView, MedicationList, MedicationDetail, AddMedication, EditMedication, Categories, Settings, BarcodeScanner, ImagePicker, MedicationCard |
| **Services** | 1 | NotificationManager |
| **Extensions** | 2 | Color+Hex, Extensions |
| **App Entry** | 1 | medicinetimeApp |
| **Tests** | 4 | Unit Tests + UI Tests |
| **Configuration** | 2 | Info.plist, entitlements |
| **Total Swift Files** | **24** | ~2,500 lines of code |

### Documentation Files (7 files)

| File | Purpose | Lines |
|------|---------|-------|
| `us.md` | English Operation Guide | ~2,000 |
| `README.md` | Project Overview & Setup | ~300 |
| `BUILD_GUIDE.md` | Build Instructions | ~400 |
| `TESTING_STANDARDS.md` | Testing Criteria | ~500 |
| `PROJECT_COMPLETION_SUMMARY.md` | Completion Summary | ~400 |
| `QUICK_START.md` | Quick Start Guide | ~300 |
| `ARCHITECTURE_DEEP_ANALYSIS.md` | Architecture Analysis | ~200 |
| **Total Documentation** | | **~4,100 lines** |

---

## 🎯 Key Files Explained

### 🚀 Entry Point

#### `medicinetimeApp.swift`
```swift
// Main app entry point
// - Creates PersistenceController (Core Data + CloudKit)
// - Creates NotificationManager
// - Sets up dependency injection
// - Launches ContentView
```

**Why Important**: Initializes the entire app, sets up Core Data stack, requests notification permissions

---

### 💾 Core Data Layer

#### `PersistenceController.swift`
```swift
// Core Data Stack with CloudKit support
// - Creates NSPersistentCloudKitContainer
// - Configures data migration
// - Sets merge policies
// - Provides save context
// - Supports background contexts
```

**Key Features**:
- ✅ Automatic data migration
- ✅ CloudKit sync ready
- ✅ Conflict resolution
- ✅ Background processing

#### `Medication+CoreDataClass.swift`
```swift
// Main Medication Entity
// - All medication properties
// - Computed properties: isExpired, daysUntilExpiry, expiryStatus, needsRestock
// - Privacy support
// - Image handling
```

**Why Important**: Core data model for medications, includes all business logic for expiry and stock tracking

---

### 🧠 ViewModel Layer

#### `MedicationViewModel.swift`
```swift
// Main Business Logic
// - CRUD operations (Create, Read, Update, Delete)
// - Search and filtering
// - Category management
// - Statistics calculation
// - NSFetchedResultsController integration
```

**Key Methods**:
- `addMedication(_:)` - Add new medication
- `updateMedication(_:)` - Update existing
- `deleteMedication(_:)` - Delete medication
- `updateStock(id:quantity:)` - Update quantity
- `filteredMedications` - Search + filter results

---

### 🎨 Views Layer

#### `ContentView.swift` (Dashboard)
```swift
// Main TabView with 4 tabs:
// 1. Dashboard - Statistics, expiring soon, low stock
// 2. Medications - List view with search/filter
// 3. Categories - Category management
// 4. Settings - App settings
```

**Components**:
- StatisticsCardsView
- ExpiringSoonSection
- LowStockSection
- QuickActionsView

#### `MedicationListView.swift`
```swift
// List of all medications
// - Search bar
// - Category filter chips
// - Medication cards
// - Swipe to delete
// - Empty state
```

#### `AddMedicationView.swift`
```swift
// Form to add new medication
// - Name (required)
// - Category picker
// - Barcode scanner button
// - Quantity stepper
// - Unit picker
// - Expiration date picker
// - Location
// - Privacy toggle
// - Notes
// - Photo attachment
```

#### `MedicationDetailView.swift`
```swift
// Full medication details
// - Large image
// - Name and category
// - Statistics (quantity, expiry)
// - Expiry status card
// - Location, purchase date, notes
// - Use/Add buttons
// - Edit/Delete actions
```

#### `BarcodeScannerView.swift`
```swift
// AVFoundation barcode scanner
// - Supports: EAN-8, EAN-13, UPC-E, Code 128, Code 39, Code 93, QR
// - Visual scan line animation
// - Haptic feedback
// - Auto-dismiss on scan
```

---

### 🔔 Services

#### `NotificationManager.swift`
```swift
// Notification scheduling and handling
// - Permission request (optimized timing)
// - 3-month expiry reminder
// - 1-month expiry reminder
// - 1-week urgent reminder
// - Expiry day notification
// - Cancel on delete
// - Handle notification actions
```

**Notification Schedule**:
```
Medication Added
    ↓
Schedule 4 notifications:
1. 3 months before expiry
2. 1 month before expiry
3. 1 week before expiry (urgent)
4. On expiry day
```

---

### 🔧 Extensions

#### `Color+Hex.swift`
```swift
// Color utilities
// - init(hex:) - Create Color from hex string
// - toHex() - Convert Color to hex string
// - App color constants:
//   - appPrimary (#007AFF)
//   - appSecondary (#5856D6)
//   - appSuccess (#34C759)
//   - appWarning (#FF9500)
//   - appError (#FF3B30)
```

#### `Extensions.swift`
```swift
// General extensions
// - Array: safe subscript
// - Date: addingDays, addingMonths, startOfDay, endOfDay
// - String: isValidEmail, toUUID
// - Int: daysToSeconds, monthsToDays
// - Optional: isNilOrEmpty
```

---

## 📋 Configuration Files

### `Info.plist`
```xml
<!-- App Configuration -->
- NSCameraUsageDescription (Camera permission)
- NSPhotoLibraryUsageDescription (Photo library permission)
- NSUserNotificationsUsageDescription (Notification permission)
- UIUserInterfaceStyle (Light mode default)
- UISupportedInterfaceOrientations (Portrait)
```

### `medicinetime.entitlements`
```xml
<!-- App Capabilities -->
- com.apple.security.application-groups
- com.apple.developer.icloud-container-identifiers
- com.apple.developer.icloud-services (CloudKit)
- com.apple.developer.ubiquity-container-identifiers
```

---

## 🎨 Component Library

### Reusable Components

#### `MedicationCard.swift`
```swift
// Used in: Dashboard, MedicationList, Categories
// Components:
// - Thumbnail (60x60)
// - Name + Category
// - ExpiryBadge
// - LowStockWarning
// - Quantity display
```

#### Sub-components:
- **ExpiryBadge**: Shows expiry status with color coding
- **LowStockWarning**: Shows low stock alert
- **StatCard**: Statistics display
- **CategoryChip**: Category filter button
- **QuickActionButton**: Dashboard action button

---

## 🧪 Testing Structure

### Unit Tests
```swift
// medicinetimeTests.swift
// Test targets:
// - MedicationViewModel
// - Model computed properties
// - Extensions
// - NotificationManager
```

### UI Tests
```swift
// medicinetimeUITests.swift
// Test flows:
// - Launch app
// - Add medication
// - Edit medication
// - Delete medication
// - Search and filter
// - Navigation
```

---

## 📖 Documentation Hierarchy

### Level 1: Main Specification
- **`us.md`** - Complete English operation guide
  - Market research
  - Technical architecture
  - UI design system
  - Implementation details
  - Testing standards

### Level 2: Project Documentation
- **`README.md`** - Project overview and quick reference
- **`BUILD_GUIDE.md`** - Detailed build instructions
- **`TESTING_STANDARDS.md`** - Testing and UI acceptance criteria

### Level 3: Quick References
- **`QUICK_START.md`** - 5-minute quick start guide
- **`PROJECT_COMPLETION_SUMMARY.md`** - What's been built
- **`PROJECT_STRUCTURE.md`** - This file

### Level 4: Analysis Documents
- **`ARCHITECTURE_DEEP_ANALYSIS.md`** - Architecture analysis
- **`US_MD_SUPPLEMENTS_SUMMARY.md`** - Supplement documentation
- **`US_MD_VERIFICATION_REPORT.md`** - Verification against original guide

---

## 🔄 Data Flow

### Add Medication Flow
```
User taps "+" → AddMedicationView
    ↓
User enters data
    ↓
User taps "Save"
    ↓
ViewModel.addMedication()
    ↓
Core Data save
    ↓
NotificationManager.scheduleExpiryNotifications()
    ↓
NSFetchedResultsController detects change
    ↓
ViewModel.medications updated
    ↓
Views automatically refresh
```

### Search Flow
```
User types in search bar
    ↓
ViewModel.searchText updated
    ↓
filteredMedications computed property
    ↓
Filters by: category + searchText
    ↓
List automatically updates
```

### Notification Flow
```
Medication added/updated
    ↓
NotificationManager.scheduleExpiryNotifications()
    ↓
4 notifications scheduled:
- 3 months before expiry
- 1 month before expiry
- 1 week before expiry
- On expiry day
    ↓
When notification fires
    ↓
User sees alert
    ↓
User can tap to open app
```

---

## 🎯 Module Dependencies

```
App (medicinetimeApp)
    ↓
├── PersistenceController (Core Data + CloudKit)
│   └── Medication, FamilyMember, MedicationUsage, Category
│
├── NotificationManager (UserNotifications)
│   └── Schedules notifications for medications
│
└── Views (SwiftUI)
    ├── ContentView (Dashboard)
    │   └── MedicationViewModel
    │       └── Core Data
    │
    ├── MedicationListView
    │   └── MedicationViewModel + Search + Filter
    │
    ├── MedicationDetailView
    │   └── Medication + Image + Usage
    │
    ├── AddMedicationView
    │   ├── BarcodeScannerView (AVFoundation)
    │   └── ImagePicker (Photos)
    │
    └── SettingsView
        └── Configuration
```

---

## 🚀 Build Order

When building the project, Xcode processes files in this order:

1. **Core Data Models** (generated classes)
2. **Extensions** (utilities)
3. **PersistenceController** (data stack)
4. **ViewModels** (business logic)
5. **Services** (notifications)
6. **Views** (UI components)
7. **App Entry Point** (medicinetimeApp)

---

## 📈 Project Metrics

### Code Distribution
- **Core Data Layer**: 20% (5 files)
- **ViewModel Layer**: 5% (1 file)
- **View Layer**: 45% (10 files + components)
- **Services**: 5% (1 file)
- **Extensions**: 10% (2 files)
- **Configuration**: 5% (2 files)
- **Tests**: 10% (4 files)

### Complexity Distribution
- **High Complexity**: MedicationViewModel, PersistenceController
- **Medium Complexity**: AddMedicationView, MedicationDetailView, NotificationManager
- **Low Complexity**: Simple views, extensions, components

---

## 🎓 Learning Path

### For New Developers

#### Week 1: Understand Architecture
1. Read `us.md` - Understand requirements
2. Read `medicinetimeApp.swift` - Understand app lifecycle
3. Read `PersistenceController.swift` - Understand Core Data
4. Read `MedicationViewModel.swift` - Understand MVVM

#### Week 2: Explore Views
1. `ContentView.swift` - Dashboard structure
2. `MedicationListView.swift` - List with search
3. `AddMedicationView.swift` - Form handling
4. `MedicationCard.swift` - Component design

#### Week 3: Advanced Features
1. `BarcodeScannerView.swift` - AVFoundation
2. `NotificationManager.swift` - UserNotifications
3. Core Data relationships
4. CloudKit configuration

#### Week 4: Testing & Deployment
1. Write unit tests
2. Write UI tests
3. Build and run on device
4. Prepare for TestFlight

---

## 🔍 File Navigation Tips

### Find a file quickly:
- **⌘ + Shift + O**: Open quickly (type filename)
- **⌘ + Shift + F**: Find in project
- **⌘ + 1**: Show project navigator
- **Right-click → Jump To**: Navigate to related files

### Understand a feature:
1. Find the View (e.g., `AddMedicationView.swift`)
2. Find the ViewModel method (e.g., `addMedication(_:)`)
3. Find the Core Data entity (e.g., `Medication+CoreDataClass.swift`)
4. Find the service (e.g., `NotificationManager.swift`)

---

## 📞 Quick Reference

### Main App File
📱 `medicinetime/medicinetimeApp.swift`

### Core Data Stack
💾 `medicinetime/CoreData/PersistenceController.swift`

### Main ViewModel
🧠 `medicinetime/ViewModels/MedicationViewModel.swift`

### Dashboard View
🏠 `medicinetime/Views/ContentView.swift`

### Notification Service
🔔 `medicinetime/Services/NotificationManager.swift`

### Color System
🎨 `medicinetime/Extensions/Color+Hex.swift`

---

*Generated: March 10, 2026*
*MedCabinet v1.0.0*
