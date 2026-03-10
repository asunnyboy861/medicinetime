# MedCabinet Testing Standards & UI Acceptance Criteria

## 🧪 Testing Standards

### 1. Unit Testing Standards

#### ViewModel Tests
```swift
// Test coverage requirements:
- ✅ All public methods tested
- ✅ Edge cases covered
- ✅ Error scenarios handled
- ✅ State changes verified

// Example test structure:
class MedicationViewModelTests: XCTestCase {
    var viewModel: MedicationViewModel!
    var persistenceController: PersistenceController!
    
    override func setUp() {
        persistenceController = .init(inMemory: true)
        viewModel = MedicationViewModel(persistenceController: persistenceController)
    }
    
    func testAddMedication() {
        // Given
        let medication = Medication(context: persistenceController.container.viewContext)
        medication.name = "Test Med"
        
        // When
        viewModel.addMedication(medication)
        
        // Then
        XCTAssertEqual(viewModel.medications.count, 1)
    }
}
```

#### Model Tests
```swift
// Test computed properties:
- ✅ isExpired
- ✅ daysUntilExpiry
- ✅ expiryStatus
- ✅ needsRestock

// Example:
func testExpiryStatus() {
    let medication = Medication(context: context)
    
    // Expired
    medication.expirationDate = Date().addingTimeInterval(-86400)
    XCTAssertEqual(medication.expiryStatus, .expired)
    
    // Expiring soon (< 30 days)
    medication.expirationDate = Date().addingTimeInterval(15 * 86400)
    XCTAssertEqual(medication.expiryStatus, .expiringSoon)
    
    // Expiring in 3 months (< 90 days)
    medication.expirationDate = Date().addingTimeInterval(60 * 86400)
    XCTAssertEqual(medication.expiryStatus, .expiringIn3Months)
    
    // Good
    medication.expirationDate = Date().addingTimeInterval(200 * 86400)
    XCTAssertEqual(medication.expiryStatus, .good)
}
```

### 2. UI Testing Standards

#### Screen Tests
```swift
// Test each screen:
- ✅ Dashboard loads correctly
- ✅ Medication list displays
- ✅ Add medication form works
- ✅ Detail view shows all info
- ✅ Settings screen accessible

// Example:
func testDashboardLoads() {
    let app = XCUIApplication()
    app.launch()
    
    // Verify statistics cards visible
    XCTAssertTrue(app.staticTexts["Total"].exists)
    XCTAssertTrue(app.staticTexts["Expiring"].exists)
    XCTAssertTrue(app.staticTexts["Low Stock"].exists)
    
    // Verify navigation
    XCTAssertTrue(app.navigationBars["MedCabinet"].exists)
}
```

#### Interaction Tests
```swift
// Test user interactions:
- ✅ Tap buttons
- ✅ Enter text
- ✅ Swipe to delete
- ✅ Pull to refresh
- ✅ Search functionality

// Example:
func testAddMedicationFlow() {
    let app = XCUIApplication()
    app.launch()
    
    // Tap add button
    app.buttons["plus.circle.fill"].tap()
    
    // Enter medication details
    let nameField = app.textFields["Medication Name"]
    nameField.tap()
    nameField.typeText("Tylenol")
    
    // Set quantity
    app.buttons["Increment"].tap()
    
    // Save
    app.buttons["Save"].tap()
    
    // Verify added
    XCTAssertTrue(app.staticTexts["Tylenol"].exists)
}
```

### 3. Integration Testing

#### Core Data Integration
```swift
// Test data persistence:
- ✅ Save medication
- ✅ Fetch medications
- ✅ Update medication
- ✅ Delete medication
- ✅ Data survives app restart

// Test CloudKit sync (when implemented):
- ✅ Add on device A, appears on device B
- ✅ Update on device A, syncs to device B
- ✅ Delete on device A, removed from device B
- ✅ Conflict resolution works
```

#### Notification Integration
```swift
// Test notification scheduling:
- ✅ Request permission
- ✅ Schedule expiry reminders
- ✅ Cancel on medication delete
- ✅ Handle notification actions

// Test notification delivery:
- ✅ 3-month reminder fires
- ✅ 1-month reminder fires
- ✅ 1-week reminder fires
- ✅ Expiry day reminder fires
```

## 🎨 UI Acceptance Criteria

### 1. Design System Compliance

#### Colors
```swift
// Verify all colors match design:
- ✅ Primary: #007AFF
- ✅ Secondary: #5856D6
- ✅ Success: #34C759
- ✅ Warning: #FF9500
- ✅ Error: #FF3B30
- ✅ Background: #F2F2F7
- ✅ Card Background: #FFFFFF
```

#### Typography
```swift
// Verify font sizes and weights:
- ✅ Large Title: SF Pro Display, 34pt, Bold
- ✅ Title: SF Pro Display, 28pt, Bold
- ✅ Headline: SF Pro Text, 17pt, Bold
- ✅ Body: SF Pro Text, 17pt, Regular
- ✅ Caption: SF Pro Text, 13pt, Regular
- ✅ Footnote: SF Pro Text, 13pt, Regular
```

#### Spacing
```swift
// Verify spacing consistency:
- ✅ Section spacing: 20pt
- ✅ Item spacing: 12pt
- ✅ Padding: 16pt
- ✅ Card padding: 12pt
- ✅ Button padding: 16pt horizontal, 12pt vertical
```

#### Corner Radius
```swift
// Verify corner radius:
- ✅ Cards: 12pt
- ✅ Buttons: 10pt
- ✅ Inputs: 10pt
- ✅ Badges: 6pt
- ✅ Large containers: 16pt
```

#### Shadows
```swift
// Verify shadow settings:
- ✅ Cards: opacity 0.05, radius 8, x: 0, y: 2
- ✅ Floating buttons: opacity 0.1, radius 12, x: 0, y: 4
- ✅ Modals: opacity 0.2, radius 20, x: 0, y: 10
```

### 2. Component Acceptance Criteria

#### Medication Card
```swift
// Must include:
- ✅ Thumbnail image (60x60pt) or placeholder icon
- ✅ Medication name (headline, bold)
- ✅ Category label (subheadline, secondary color)
- ✅ Expiry badge with correct color
- ✅ Low stock warning (if applicable)
- ✅ Quantity display (large, bold)
- ✅ Unit label (caption, secondary)

// Behavior:
- ✅ Tappable (navigates to detail)
- ✅ Swipe to delete
- ✅ Long press for quick actions
```

#### Statistics Card
```swift
// Must include:
- ✅ Icon (title2, colored)
- ✅ Value (title, bold)
- ✅ Label (caption, secondary)
- ✅ Background color (white)
- ✅ Corner radius (12pt)

// States:
- ✅ Normal
- ✅ Warning (for expiring/low stock)
- ✅ Error (for expired)
```

#### Expiry Badge
```swift
// Must display:
- ✅ Icon based on status
- ✅ Days remaining or "Expired"
- ✅ Correct background color (10% opacity)
- ✅ Correct text color (100% opacity)
- ✅ Corner radius (6pt)

// Status colors:
- ✅ Expired: Red (#FF3B30)
- ✅ Expiring Soon (< 30 days): Orange (#FF9500)
- ✅ Expiring in 3 Months (< 90 days): Yellow (#FFCC00)
- ✅ Good: Green (#34C759)
```

#### Buttons
```swift
// Primary Button:
- ✅ Background: appPrimary
- ✅ Text: White
- ✅ Height: 44pt minimum
- ✅ Corner radius: 10pt
- ✅ Font: Body (17pt), Semibold

// Secondary Button:
- ✅ Background: Clear or appPrimary.opacity(0.1)
- ✅ Text: appPrimary
- ✅ Border: 1pt appPrimary
- ✅ Height: 44pt minimum
- ✅ Corner radius: 10pt

// Destructive Button:
- ✅ Background: appError
- ✅ Text: White
- ✅ Height: 44pt minimum
- ✅ Corner radius: 10pt
```

#### Search Bar
```swift
// Must include:
- ✅ Search icon (leading)
- ✅ Placeholder text: "Search medications"
- ✅ Clear button (trailing, when text entered)
- ✅ Background: appBackground
- ✅ Corner radius: 10pt
- ✅ Padding: 10pt

// Behavior:
- ✅ Real-time filtering
- ✅ Case-insensitive search
- ✅ Searches name and notes
```

#### Category Chip
```swift
// Must include:
- ✅ Icon (caption size)
- ✅ Category name (subheadline, medium)
- ✅ Background: Color or 10% opacity
- ✅ Text: White or color
- ✅ Corner radius: 20pt
- ✅ Padding: 12pt horizontal, 8pt vertical

// States:
- ✅ Selected: Solid background, white text
- ✅ Unselected: 10% opacity background, colored text
```

### 3. Screen Acceptance Criteria

#### Dashboard Screen
```swift
// Layout:
- ✅ Navigation title: "MedCabinet"
- ✅ Add button (top right)
- ✅ ScrollView for content
- ✅ Safe area respected

// Content:
- ✅ Statistics cards (3 cards in HStack)
- ✅ Expiring Soon section (if applicable)
- ✅ Low Stock section (if applicable)
- ✅ Quick Actions section

// Empty States:
- ✅ No medications: Show empty state with CTA
- ✅ No expiring: Hide section
- ✅ No low stock: Hide section
```

#### Medication List Screen
```swift
// Layout:
- ✅ Navigation title: "Medications"
- ✅ Search bar (below navigation)
- ✅ Category filter (horizontal scroll)
- ✅ List of medication cards
- ✅ Add button (top right or FAB)

// Behavior:
- ✅ Pull to refresh
- ✅ Swipe to delete
- ✅ Tap to navigate to detail
- ✅ Search filters in real-time
- ✅ Category filter updates list
```

#### Medication Detail Screen
```swift
// Layout:
- ✅ Large image (250pt height)
- ✅ Info card with rounded corners
- ✅ Name and category at top
- ✅ Statistics boxes (quantity, expiry)
- ✅ Expiry status card
- ✅ Location, purchase date, notes
- ✅ Action buttons (Use, Add, Edit)

// Toolbar:
- ✅ Close button (leading)
- ✅ More menu (trailing)
  - Share option
  - Edit option
  - Delete option (destructive)
```

#### Add Medication Screen
```swift
// Layout:
- ✅ Form layout
- ✅ Sections:
  - Basic Information
  - Quantity & Stock
  - Dates
  - Storage
  - Notes
  - Photo

// Fields:
- ✅ Name (required)
- ✅ Category picker
- ✅ Barcode scanner button
- ✅ Quantity stepper
- ✅ Unit picker
- ✅ Low stock threshold stepper
- ✅ Expiration date picker
- ✅ Purchase date picker
- ✅ Location text field
- ✅ Private toggle
- ✅ Notes text field
- ✅ Photo button

// Validation:
- ✅ Name required (disable save if empty)
- ✅ Expiration date must be in future
- ✅ Quantity must be non-negative

// Toolbar:
- ✅ Cancel button (leading)
- ✅ Save button (trailing, disabled until valid)
```

### 4. Animation Standards

#### Transitions
```swift
// Screen transitions:
- ✅ Push/pop: 0.3s, easeInOut
- ✅ Modal present/dismiss: 0.35s, spring
- ✅ Tab switch: 0.25s, easeInOut

// Element transitions:
- ✅ Fade in: 0.2s
- ✅ Slide up: 0.3s, spring
- ✅ Scale: 0.2s, spring (damping: 0.8)
```

#### Micro-interactions
```swift
// Button press:
- ✅ Scale down to 0.95 on touch
- ✅ Return to 1.0 on release
- ✅ Duration: 0.1s

// Loading states:
- ✅ Spinner: Continuous rotation
- ✅ Speed: 1 rotation per second
- ✅ Size: 20x20pt

// Success feedback:
- ✅ Checkmark animation: 0.3s
- ✅ Scale + opacity
- ✅ Haptic feedback: .success
```

### 5. Accessibility Standards

#### VoiceOver
```swift
// All elements must have:
- ✅ Accessibility labels
- ✅ Accessibility hints
- ✅ Correct reading order
- ✅ Appropriate traits

// Example:
Image(systemName: "pill.fill")
    .accessibilityLabel("Medication")
    .accessibilityHint("Tap to view details")
    .accessibilityAddTraits(.isButton)
```

#### Dynamic Type
```swift
// All text must support:
- ✅ Dynamic Type scaling
- ✅ Minimum font size: 11pt
- ✅ Maximum font size: 28pt
- ✅ Line wrapping enabled

// Use:
Text("Hello")
    .font(.body)
    .accessibilityAdjustableAction { _ in }
```

#### Contrast
```swift
// Minimum contrast ratios:
- ✅ Normal text: 4.5:1
- ✅ Large text: 3:1
- ✅ UI elements: 3:1

// Test with:
- ✅ Normal vision
- ✅ Color blindness simulations
- ✅ High contrast mode
```

### 6. Performance Standards

#### Frame Rate
```swift
// Must maintain:
- ✅ 60 FPS during scrolling
- ✅ 60 FPS during animations
- ✅ No dropped frames
- ✅ Smooth transitions
```

#### Memory
```swift
// Limits:
- ✅ Initial launch: < 50 MB
- ✅ With 100 medications: < 100 MB
- ✅ Image loading: < 150 MB peak
- ✅ No memory leaks
```

#### Battery
```swift
// Impact:
- ✅ Background fetch: < 1% per hour
- ✅ Active usage: ~5% per hour
- ✅ Notifications: Minimal impact
```

## 📋 Testing Checklist

### Pre-Release Checklist
- [ ] All unit tests pass
- [ ] All UI tests pass
- [ ] Manual testing completed
- [ ] Performance benchmarks met
- [ ] Accessibility audit passed
- [ ] UI acceptance criteria met
- [ ] No console warnings
- [ ] No memory leaks
- [ ] Battery impact acceptable
- [ ] App Store guidelines compliance

### Regression Testing
- [ ] Core flows work after changes
- [ ] Existing features not broken
- [ ] Data migration works
- [ ] Notifications still fire
- [ ] Search still works
- [ ] Categories still filter

### Device Testing
- [ ] iPhone 15 Pro Max
- [ ] iPhone 15
- [ ] iPhone 14 Pro
- [ ] iPhone 13
- [ ] iPhone SE
- [ ] iPad Pro
- [ ] iPad Air
- [ ] All screen sizes

### iOS Version Testing
- [ ] iOS 17.0
- [ ] iOS 17.1
- [ ] iOS 17.2
- [ ] iOS 17.3+

## 🐛 Bug Severity Levels

### Critical (P0)
- App crashes
- Data loss
- Security vulnerability
- Blocks core functionality

### High (P1)
- Major feature broken
- Significant UI issue
- Performance degradation
- Data sync issues

### Medium (P2)
- Minor feature broken
- UI inconsistency
- Edge case failure
- Non-critical bug

### Low (P3)
- Cosmetic issue
- Typo
- Minor inconvenience
- Enhancement request

## 📊 Quality Metrics

### Code Quality
- ✅ SwiftLint: 0 warnings, 0 errors
- ✅ Test coverage: > 80%
- ✅ Cyclomatic complexity: < 15
- ✅ File length: < 500 lines
- ✅ Function length: < 50 lines

### UI Quality
- ✅ Design consistency: 100%
- ✅ Accessibility: WCAG 2.1 AA
- ✅ Performance: 60 FPS
- ✅ Memory: Within limits
- ✅ Battery: Minimal impact

### User Experience
- ✅ Launch time: < 1.5s
- ✅ Interaction latency: < 100ms
- ✅ Search response: < 50ms
- ✅ Save operation: < 200ms
- ✅ Navigation: Instant
