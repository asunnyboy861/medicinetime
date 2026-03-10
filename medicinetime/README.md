# MedCabinet - iOS Medication Inventory Tracker

## 📱 Project Structure

```
medicinetime/
├── medicinetimeApp.swift          # Main app entry point
├── ContentView.swift               # Main tab view
├── CoreData/
│   ├── PersistenceController.swift # Core Data stack
│   ├── Medication+CoreDataClass.swift
│   ├── FamilyMember+CoreDataClass.swift
│   ├── MedicationUsage+CoreDataClass.swift
│   ├── Category+CoreDataClass.swift
│   └── MedCabinet.xcdatamodeld/   # Data model
├── ViewModels/
│   └── MedicationViewModel.swift   # Main ViewModel
├── Views/
│   ├── ContentView.swift           # Dashboard & TabView
│   ├── MedicationListView.swift    # List view with search
│   ├── MedicationDetailView.swift  # Detail view
│   ├── AddMedicationView.swift     # Add medication form
│   ├── EditMedicationView.swift    # Edit medication form
│   ├── CategoriesView.swift        # Categories management
│   ├── SettingsView.swift          # App settings
│   ├── BarcodeScannerView.swift    # Barcode scanner
│   ├── ImagePicker.swift           # Image picker
│   └── Components/
│       └── MedicationCard.swift    # Reusable card component
├── Services/
│   └── NotificationManager.swift   # Notification handling
├── Extensions/
│   ├── Color+Hex.swift             # Color utilities
│   └── Extensions.swift            # General extensions
├── Info.plist                      # App configuration
└── medicinetime.entitlements       # App capabilities
```

## 🚀 Features Implemented

### Core Features
- ✅ **Medication Management**: Add, edit, delete medications
- ✅ **Barcode Scanning**: AVFoundation-based barcode scanner
- ✅ **Expiry Tracking**: Automatic expiration date monitoring
- ✅ **Low Stock Alerts**: Configurable stock level warnings
- ✅ **Category System**: Pre-defined and custom categories
- ✅ **Search & Filter**: Real-time search and category filtering
- ✅ **Photo Attachment**: Take or select medication photos
- ✅ **Privacy Mode**: Hide sensitive medications from family members

### Notification System
- ✅ 3-month expiry reminder
- ✅ 1-month expiry reminder
- ✅ 1-week urgent reminder
- ✅ Expiry day notification
- ✅ Low stock alerts

### Data Management
- ✅ Core Data local storage
- ✅ CloudKit sync (configured)
- ✅ Data migration support
- ✅ Automatic backups

## 🛠️ Technical Stack

- **Minimum iOS**: 17.0
- **Framework**: SwiftUI
- **Architecture**: MVVM
- **Database**: Core Data + CloudKit
- **Notifications**: UserNotifications
- **Barcode**: AVFoundation + Vision

## 📋 Setup Instructions

### 1. Open Project
```bash
open medicinetime.xcodeproj
```

### 2. Configure Signing
- Select project in Xcode
- Go to "Signing & Capabilities"
- Select your development team
- Enable "Automatically manage signing"

### 3. Enable CloudKit (Optional)
- Create new CloudKit container in Apple Developer Portal
- Update `medicinetime.entitlements` with your container ID
- Configure CloudKit permissions in Xcode

### 4. Build and Run
- Select target device/simulator
- Press ⌘R to build and run

## 🎨 UI Design System

### Colors
```swift
Color.appPrimary      = #007AFF  // Apple Blue
Color.appSecondary    = #5856D6  // Purple
Color.appSuccess      = #34C759  // Green
Color.appWarning      = #FF9500  // Orange
Color.appError        = #FF3B30  // Red
Color.appBackground   = #F2F2F7  // Light Gray
Color.appCardBackground = #FFFFFF // White
```

### Typography
- **Title**: SF Pro Display, Bold, 28pt
- **Headline**: SF Pro Text, Bold, 17pt
- **Body**: SF Pro Text, Regular, 17pt
- **Caption**: SF Pro Text, Regular, 13pt

### Components
- **Cards**: 12pt corner radius, subtle shadow
- **Buttons**: SF Symbols + text, 16pt horizontal padding
- **Inputs**: 10pt padding, rounded corners

## 📊 Data Model

### Medication Entity
```swift
- id: UUID
- name: String
- barcode: String?
- category: String
- expirationDate: Date
- purchaseDate: Date
- quantity: Int16
- unit: String
- dosage: String?
- notes: String?
- imageData: Data?
- thumbnailData: Data?
- location: String?
- familyID: String?
- isPrivate: Bool
- isLowStock: Bool
- lowStockThreshold: Int16
- averageUsagePerMonth: Double
- lastUsedDate: Date?
- lastUpdated: Date
```

### Category Entity
```swift
- id: UUID
- name: String
- icon: String (SF Symbol)
- color: String (Hex)
- sortOrder: Int16
```

## 🔔 Notification Categories

1. **EXPIRY_REMINDER**: 3-month and 1-month warnings
2. **EXPIRY_URGENT**: 1-week urgent reminder
3. **EXPIRY_EXPIRED**: Expiry day notification

## 📸 Image Handling

### Compression Strategy
```swift
- Max dimension: 1200px
- Compression quality: 80%
- Thumbnail size: 150x150px
- Storage: Core Data (imageData + thumbnailData)
```

## 🧪 Testing

### Unit Tests
- ViewModel logic
- Data calculations
- Expiry status

### UI Tests
- Navigation flow
- Add/Edit/Delete operations
- Search and filter

## 🚀 Next Steps

### High Priority
- [ ] Implement CloudKit sync logic
- [ ] Add PDF/CSV export functionality
- [ ] Implement family sharing
- [ ] Add usage statistics charts

### Medium Priority
- [ ] Implement barcode database lookup
- [ ] Add medication interaction warnings
- [ ] Implement refill reminders
- [ ] Add home screen widgets

### Low Priority
- [ ] Implement Apple Health integration
- [ ] Add multi-language support
- [ ] Implement dark mode
- [ ] Add accessibility improvements

## 📝 Code Conventions

### Naming
- **Views**: PascalCase + "View" suffix (e.g., `MedicationListView`)
- **ViewModels**: PascalCase + "ViewModel" suffix
- **Models**: PascalCase (e.g., `Medication`, `Category`)
- **Extensions**: PascalCase + extension type (e.g., `Color+Hex`)

### Architecture
- Single responsibility per file
- MVVM pattern throughout
- SwiftUI first, UIKit when necessary
- Protocol-oriented programming

### Comments
- Document public APIs
- Explain complex logic
- Use `// MARK:` for sections

## 🐛 Known Issues

1. **CloudKit Sync**: Not yet implemented
2. **Barcode Lookup**: Requires external API integration
3. **PDF Export**: Not yet implemented

## 📄 License

MIT License - See LICENSE file for details

## 👥 Contributors

Built following the guidelines in `us.md`

## 📞 Support

For issues and feature requests, please create a GitHub issue.
