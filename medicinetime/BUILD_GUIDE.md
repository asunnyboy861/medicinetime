# MedCabinet Build & Compilation Guide

## ✅ Build Checklist

### Prerequisites
- [ ] Xcode 15.0 or later installed
- [ ] iOS 17.0+ deployment target
- [ ] Apple Developer account (for signing)
- [ ] macOS Ventura 13.0 or later

### Project Setup
- [ ] Open `medicinetime.xcodeproj` in Xcode
- [ ] Select your development team in Signing & Capabilities
- [ ] Verify bundle identifier: `com.medcabinet.app`
- [ ] Check entitlements file is properly configured

## 🔨 Build Steps

### 1. Clean Build Folder
```bash
# In Xcode: Product → Clean Build Folder
# Or use keyboard shortcut: Shift + ⌘ + K
```

### 2. Resolve Dependencies
```bash
# Xcode will automatically resolve Swift Package dependencies
# Check: File → Add Packages → Show Package Dependencies
```

### 3. Build for Running
```bash
# In Xcode: Product → Run
# Or use keyboard shortcut: ⌘ + R
```

### 4. Build for Testing
```bash
# In Xcode: Product → Test
# Or use keyboard shortcut: ⌘ + U
```

### 5. Archive for Distribution
```bash
# In Xcode: Product → Archive
# Then: Organizer → Distribute App
```

## 📋 Compilation Verification

### Expected Warnings
- None (project should compile warning-free)

### Expected Errors
- None (project should compile error-free)

### Common Issues & Solutions

#### Issue 1: "No such module 'CoreData'"
**Solution**: Check that CoreData framework is linked
- Go to: Project → Targets → General → Frameworks
- Add: CoreData.framework

#### Issue 2: "Signing certificate not found"
**Solution**: 
1. Xcode → Preferences → Accounts
2. Select your Apple ID
3. Click "Manage Certificates"
4. Add iOS Distribution certificate

#### Issue 3: "CloudKit container not found"
**Solution**:
1. Update `medicinetime.entitlements` with your container ID
2. Create container in Apple Developer Portal
3. Wait 5-10 minutes for propagation

## 🧪 Testing Checklist

### Unit Tests
```bash
# Run all unit tests
⌘ + U

# Expected: All tests pass
# Coverage target: >80%
```

### UI Tests
```bash
# Run UI tests
# Test target: medicinetimeUITests

# Test cases:
- Launch app
- Add medication
- Edit medication
- Delete medication
- Search medications
- Filter by category
```

### Manual Testing

#### Core Flows
1. **Add Medication Flow**
   - [ ] Tap "+" button
   - [ ] Enter medication name
   - [ ] Select category
   - [ ] Set quantity and unit
   - [ ] Set expiration date
   - [ ] Add photo (optional)
   - [ ] Save
   - [ ] Verify appears in list

2. **Edit Medication Flow**
   - [ ] Open medication detail
   - [ ] Tap "Edit"
   - [ ] Modify fields
   - [ ] Save
   - [ ] Verify changes persisted

3. **Delete Medication Flow**
   - [ ] Swipe to delete in list
   - [ ] Confirm deletion
   - [ ] Verify removed from list

4. **Search Flow**
   - [ ] Enter search text
   - [ ] Verify filtered results
   - [ ] Clear search
   - [ ] Verify all results shown

5. **Barcode Scanner Flow**
   - [ ] Tap "Scan Barcode"
   - [ ] Grant camera permission
   - [ ] Scan valid barcode
   - [ ] Verify barcode captured

6. **Notification Flow**
   - [ ] Add medication with near expiry
   - [ ] Grant notification permission
   - [ ] Wait for scheduled notification
   - [ ] Verify notification received

## 📱 Device Compatibility

### Tested Devices
- ✅ iPhone 15 Pro Max (iOS 17.0+)
- ✅ iPhone 15 (iOS 17.0+)
- ✅ iPhone 14 Pro (iOS 17.0+)
- ✅ iPhone 13 (iOS 17.0+)
- ✅ iPhone SE (3rd gen) (iOS 17.0+)
- ✅ iPad Pro 12.9" (iPadOS 17.0+)

### Screen Sizes Supported
- 4.7" (iPhone SE)
- 5.4" (iPhone 12/13 mini)
- 6.1" (iPhone 12/13/14/15)
- 6.7" (iPhone 14/15 Plus, Pro Max)
- 8.3" (iPad mini)
- 10.9" (iPad Air)
- 12.9" (iPad Pro)

## 🎯 Performance Benchmarks

### Launch Time
- Cold start: < 1.5 seconds
- Warm start: < 0.5 seconds

### Memory Usage
- Initial launch: < 50 MB
- With 100 medications: < 100 MB
- Peak usage: < 150 MB

### Battery Impact
- Background fetch: Minimal (< 1% per hour)
- Active usage: ~5% per hour

### Database Performance
- Load 100 medications: < 100ms
- Search query: < 50ms
- Add medication: < 200ms
- Save context: < 50ms

## 📊 Code Quality Metrics

### SwiftLint Rules (if added)
```yaml
disabled_rules:
  - line_length
  - function_body_length

opt_in_rules:
  - explicit_init
  - redundant_discardable_let
```

### File Structure
- Max lines per file: 500
- Max functions per file: 20
- Max cyclomatic complexity: 15

### Documentation
- Public APIs documented: 100%
- Code comments for complex logic: Yes
- README comprehensive: Yes

## 🚀 Deployment

### TestFlight Deployment
1. Archive app (Product → Archive)
2. Upload to App Store Connect
3. Select build in TestFlight tab
4. Add release notes
5. Submit for beta review
6. Add internal testers
7. Wait for approval (~24 hours)

### App Store Deployment
1. Create app record in App Store Connect
2. Fill app metadata
3. Upload screenshots
4. Set pricing and availability
5. Submit for review
6. Wait for approval (~2-3 days)
7. Release on scheduled date

## 📝 Version History

### Version 1.0.0 (Initial Release)
- Core medication management
- Barcode scanning
- Expiry tracking
- Low stock alerts
- Category system
- Search and filter
- Photo attachment
- Privacy mode
- Notification system

### Planned Versions

#### Version 1.1.0
- CloudKit sync
- Family sharing
- Usage statistics
- Export to PDF/CSV

#### Version 1.2.0
- Apple Health integration
- Home screen widgets
- Dark mode
- Accessibility improvements

#### Version 2.0.0
- Medication interaction warnings
- Refill reminders
- Multi-language support
- Watch app

## 🔧 Troubleshooting

### Build Fails
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Restart Xcode
killall Xcode

# Reopen project
open medicinetime.xcodeproj
```

### Runtime Crashes
```bash
# Check console logs
# Xcode → View → Debug Area → Activate Console

# Common causes:
- Missing Core Data model
- Invalid entitlements
- Permission denied
```

### Simulator Issues
```bash
# Reset simulator
simctl erase all

# Delete simulator
xcrun simctl delete unavailable
```

## 📞 Support

For build issues:
1. Check this guide first
2. Search existing GitHub issues
3. Create new issue with:
   - Xcode version
   - macOS version
   - Error message
   - Steps to reproduce
