# Apple App Store Submission Checklist - Saliena Estate App

## 📋 Complete Pre-Submission Checklist

This checklist ensures your Saliena Estate app meets all Apple App Store requirements and guidelines for 2024-2026.

---

## 🔧 1. Technical Requirements

### ✅ Build Configuration
- [ ] **Release Build Only**: Build in Release mode (not Debug)
- [ ] **iOS SDK**: Built with iOS 17 SDK or later (Xcode 15+)
- [ ] **Minimum Deployment Target**: Set to iOS 15.0 or later
- [ ] **Architecture**: Supports arm64 (required for all new submissions)
- [ ] **Remove Debug Code**: No `print()`, `debugPrint()`, or test code
- [ ] **No Placeholder Content**: All screens have real content

### ✅ App Stability
- [ ] **No Crashes**: Test thoroughly on real devices
- [ ] **Memory Management**: No significant memory leaks
- [ ] **Performance**: Fast app launch (under 3 seconds)
- [ ] **Network Handling**: Graceful offline/poor connection handling
- [ ] **Error Handling**: All error states handled properly

### ✅ Device Testing
Test on these devices minimum:
- [ ] iPhone SE (3rd generation) - smallest screen
- [ ] iPhone 15 - standard size
- [ ] iPhone 15 Pro Max - largest screen
- [ ] iPad (if supporting iPad)

---

## 🎨 2. User Interface & Experience

### ✅ Apple Human Interface Guidelines (HIG)
- [ ] **Native iOS Feel**: Follows iOS design patterns
- [ ] **Navigation**: Uses standard iOS navigation patterns
- [ ] **Touch Targets**: Minimum 44x44 points for tappable elements
- [ ] **Safe Areas**: Respects iPhone notch/Dynamic Island
- [ ] **Accessibility**: VoiceOver support, Dynamic Type support

### ✅ Dark Mode Support
- [ ] **Light Mode**: All screens work in light mode
- [ ] **Dark Mode**: All screens work in dark mode
- [ ] **Automatic Switching**: Respects system setting
- [ ] **Colors**: Use semantic colors that adapt

### ✅ Orientation Support
- [ ] **Portrait**: Primary orientation works perfectly
- [ ] **Landscape**: If supported, works on all screens
- [ ] **Rotation**: Smooth transitions between orientations

---

## 🔐 3. Privacy & Permissions

### ✅ Permission Requests
Update your `Info.plist` with clear, specific descriptions:

```xml
<!-- Current permissions in your app -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Saliena Estate uses your location to automatically tag issue reports with the correct address and show nearby community issues.</string>

<key>NSCameraUsageDescription</key>
<string>Saliena Estate needs camera access to take photos of community issues like potholes, broken lights, or maintenance problems.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Saliena Estate needs access to your photo library to attach existing photos to issue reports.</string>

<key>NSMicrophoneUsageDescription</key>
<string>Saliena Estate needs microphone access to record videos with audio for detailed issue reports.</string>
```

### ✅ App Privacy Labels (Critical!)
In App Store Connect, you MUST declare:

**Data Linked to User:**
- [ ] Email Address (for authentication)
- [ ] Name (user profile)
- [ ] Phone Number (user profile)
- [ ] Physical Address (user profile)
- [ ] Photos (issue reports)
- [ ] Location (issue reports)

**Data Usage:**
- [ ] App Functionality (all data used for core features)
- [ ] Analytics (if using any analytics)
- [ ] Product Personalization (user-specific content)

**Third-Party Data:**
- [ ] Supabase (backend service) - declare data shared

### ✅ Privacy Policy (Required!)
Create a privacy policy that covers:
- [ ] What data you collect
- [ ] How you use the data
- [ ] Data sharing (with Supabase)
- [ ] User rights (access, deletion)
- [ ] Contact information
- [ ] Host it on a public URL (not in-app)

---

## 📱 4. App Store Connect Setup

### ✅ App Information
- [ ] **App Name**: "Saliena Estate" (matches your bundle)
- [ ] **Subtitle**: "Community Issue Reporting" (30 chars max)
- [ ] **Bundle ID**: Matches your Xcode project
- [ ] **SKU**: Unique identifier for your app
- [ ] **Primary Language**: English (or your primary language)

### ✅ App Description
Write a clear, honest description:
```
Saliena Estate is the official community app for residents to report and track maintenance issues like potholes, broken streetlights, and other infrastructure problems.

Features:
• Report issues with photos and location
• Track the status of your reports
• View community issues on an interactive map
• Receive notifications when issues are resolved
• Multi-language support (English, Latvian, Russian)

Note: This app is exclusively for Saliena Estate residents. Accounts are created by the management office.
```

### ✅ Keywords (100 characters max)
```
community,estate,maintenance,reporting,issues,residents,property,management
```

### ✅ App Category
- [ ] **Primary**: Utilities
- [ ] **Secondary**: Productivity

### ✅ Age Rating
Complete the age rating questionnaire:
- [ ] No objectionable content
- [ ] No violence, profanity, or adult themes
- [ ] Likely rating: 4+ (suitable for all ages)

---

## 📸 5. App Store Screenshots & Media

### ✅ Required Screenshots
Create screenshots for:
- [ ] **iPhone 6.7"** (iPhone 15 Pro Max): 1290 x 2796 pixels
- [ ] **iPhone 6.5"** (iPhone 14 Plus): 1242 x 2688 pixels  
- [ ] **iPhone 5.5"** (iPhone 8 Plus): 1242 x 2208 pixels

### ✅ Screenshot Content
Show these key screens:
1. **Login Screen** - "Secure resident access"
2. **Home/Reports List** - "Track community issues"
3. **Create Report** - "Report issues easily"
4. **Map View** - "See issues on map"
5. **Report Detail** - "Detailed issue tracking"

### ✅ Screenshot Guidelines
- [ ] **Real Content**: Use actual app screens, not mockups
- [ ] **No Promotional Text**: Screenshots show UI only
- [ ] **High Quality**: Crisp, clear images
- [ ] **Consistent**: Same device frame/style
- [ ] **Status Bar**: Clean status bar (full battery, good signal)

### ✅ App Preview Video (Optional but Recommended)
- [ ] **Duration**: 15-30 seconds
- [ ] **Content**: Show key features in action
- [ ] **Quality**: 1080p minimum
- [ ] **No Audio**: Visual demonstration only

---

## 🏢 6. Business & Legal

### ✅ Developer Account
- [ ] **Apple Developer Program**: Active membership ($99/year)
- [ ] **Team Role**: Admin or App Manager permissions
- [ ] **Agreements**: All agreements accepted in App Store Connect

### ✅ App-Specific Requirements
Since your app is for a specific community:
- [ ] **Geographic Restriction**: Consider restricting to Latvia/your region
- [ ] **Clear Audience**: Description clearly states "for Saliena Estate residents"
- [ ] **No Misleading Claims**: Don't claim it works for other communities

### ✅ Contact Information
- [ ] **Support URL**: Working support website or email
- [ ] **Marketing URL**: Optional website about the app
- [ ] **Privacy Policy URL**: Required, publicly accessible

---

## 🧪 7. Testing & Quality Assurance

### ✅ TestFlight Testing (Highly Recommended)
- [ ] **Internal Testing**: Test with your team
- [ ] **External Testing**: Test with actual residents
- [ ] **Feedback Collection**: Gather and address feedback
- [ ] **Multiple Builds**: Test several iterations

### ✅ Core Functionality Testing
Test these critical flows:
- [ ] **Login Flow**: Email → OTP → Success
- [ ] **Create Report**: Photos → Location → Submit
- [ ] **View Reports**: List → Detail → Map
- [ ] **Offline Handling**: No internet → Graceful degradation
- [ ] **Push Notifications**: If implemented

### ✅ Edge Cases
- [ ] **No Internet**: App doesn't crash
- [ ] **Poor Signal**: Handles timeouts gracefully
- [ ] **Full Storage**: Handles photo storage issues
- [ ] **Location Denied**: App still functions
- [ ] **Camera Denied**: Shows appropriate message

---

## 📋 8. Pre-Submission Final Checks

### ✅ App Store Connect Completion
- [ ] **All Required Fields**: Completed in App Store Connect
- [ ] **Screenshots Uploaded**: All required sizes
- [ ] **App Privacy**: All questions answered accurately
- [ ] **Pricing**: Set to Free (for your use case)
- [ ] **Availability**: Set correct countries/regions

### ✅ Build Upload
- [ ] **Archive Created**: In Xcode, Product → Archive
- [ ] **Upload Successful**: No errors during upload
- [ ] **Processing Complete**: Build shows as "Ready for Review"
- [ ] **Version Numbers**: Match between Xcode and App Store Connect

### ✅ Review Information
- [ ] **Demo Account**: Provide test login credentials for Apple reviewers
- [ ] **Review Notes**: Explain that accounts are created by management
- [ ] **Contact Info**: Working phone/email for Apple to reach you

---

## 🚀 9. Submission Process

### ✅ Submit for Review
1. **Final Review**: Double-check everything above
2. **Submit**: Click "Submit for Review" in App Store Connect
3. **Status Tracking**: Monitor review status
4. **Response Time**: Typically 24-48 hours

### ✅ Common Rejection Reasons to Avoid
- [ ] **Inaccurate Privacy Labels**: Most common rejection
- [ ] **Missing Demo Account**: For restricted apps
- [ ] **Broken Functionality**: Any crashes or major bugs
- [ ] **Misleading Metadata**: Screenshots don't match app
- [ ] **Permission Issues**: Unclear permission descriptions

---

## 📞 10. Demo Account for Apple Reviewers

Since your app requires management-created accounts, provide Apple with:

```
Demo Account Information:
Email: reviewer@saliena-demo.com
Instructions: 
1. Enter the email address
2. Tap "Send verification code"
3. Check email for OTP code
4. Enter code to access the app

Note: This is a demo account created specifically for App Store review. 
Real resident accounts are created by the Saliena Estate management office.
```

---

## ⚠️ Critical Success Factors

### 🎯 Most Important Items (Fix These First!)
1. **Privacy Labels**: Must be 100% accurate
2. **Demo Account**: Must work for Apple reviewers
3. **No Crashes**: App must be stable
4. **Clear Purpose**: Description clearly explains the app's purpose
5. **Permission Descriptions**: Must be specific and clear

### 🔄 If Rejected
1. **Read Carefully**: Apple provides specific rejection reasons
2. **Fix Issues**: Address each point mentioned
3. **Test Again**: Ensure fixes work
4. **Resubmit**: Upload new build if needed
5. **Response Time**: Usually faster on resubmission

---

## 📋 Quick Pre-Submit Checklist

**30 minutes before submission:**
- [ ] Test login flow one more time
- [ ] Verify all screenshots are correct
- [ ] Check privacy labels are accurate
- [ ] Confirm demo account works
- [ ] Review app description for typos
- [ ] Ensure build is in Release mode
- [ ] Verify version numbers match

---

## 📞 Support Resources

- **Apple Developer Support**: [developer.apple.com/support](https://developer.apple.com/support)
- **App Store Review Guidelines**: [developer.apple.com/app-store/review/guidelines](https://developer.apple.com/app-store/review/guidelines)
- **Human Interface Guidelines**: [developer.apple.com/design/human-interface-guidelines](https://developer.apple.com/design/human-interface-guidelines)
- **App Store Connect Help**: [help.apple.com/app-store-connect](https://help.apple.com/app-store-connect)

---

**Good luck with your submission! 🍀**

*This checklist is specifically tailored for the Saliena Estate community app and follows Apple's 2024-2026 guidelines.*