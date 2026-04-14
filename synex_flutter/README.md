# Synex Tournament â€” Flutter App + Admin Panel

## ðŸ“ Folder Structure
```
synex_flutter/     â†’ Flutter User App (Android APK)
synex-admin/       â†’ React Admin Panel (Render deploy)
```

---

## ðŸš€ FLUTTER APP SETUP

### Step 1 â€” Flutter Install karo
```bash
# Flutter SDK download: flutter.dev/docs/get-started/install
# Android Studio install karo
# flutter doctor run karo â€” sab green hona chahiye
```

### Step 2 â€” Project setup
```bash
cd synex_flutter
flutter pub get
```

### Step 3 â€” Google Sign In ke liye SHA-1 add karo
```bash
# Debug SHA-1:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Firebase Console â†’ DGsell â†’ Project Settings
# â†’ Your apps â†’ Android app â†’ Add fingerprint
# SHA-1 paste karo
```

### Step 4 â€” google-services.json download karo
```
Firebase Console â†’ DGsell â†’ Project Settings
â†’ Your apps â†’ Android app
â†’ Download google-services.json
â†’ android/app/ folder mein rakho
```

### Step 5 â€” APK Build karo
```bash
# Debug APK (testing ke liye):
flutter build apk --debug

# Release APK (production):
flutter build apk --release

# APK milega:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## ðŸ”¥ FIREBASE SETUP

### Realtime Database Rules (Copy paste karo):
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('isAdmin').val() == true)",
        ".write": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('isAdmin').val() == true)"
      }
    },
    "tournaments": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('isAdmin').val() == true"
    },
    "depositRequests": {
      ".read": "auth != null && root.child('users').child(auth.uid).child('isAdmin').val() == true",
      "$rid": { ".write": "auth != null" }
    },
    "withdrawalRequests": {
      ".read": "auth != null && root.child('users').child(auth.uid).child('isAdmin').val() == true",
      "$rid": { ".write": "auth != null" }
    },
    "notifications": {
      "$uid": {
        ".read": "auth.uid == $uid",
        ".write": "auth != null && (auth.uid == $uid || root.child('users').child(auth.uid).child('isAdmin').val() == true)"
      }
    },
    "spinHistory": {
      "$uid": {
        ".read": "auth.uid == $uid",
        ".write": "auth.uid == $uid"
      }
    },
    "liveStream": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('isAdmin').val() == true"
    },
    "settings": {
      ".read": true,
      ".write": "auth != null && root.child('users').child(auth.uid).child('isAdmin').val() == true"
    },
    "adminEmails": {
      ".read": false,
      ".write": false
    }
  }
}
```

### Admin Email Add karo:
```
Firebase Console â†’ DGsell â†’ Realtime Database â†’ Data
â†’ Root pe + click:

adminEmails
  â””â”€â”€ admin1: "tumhara.admin@gmail.com"
```

---

## ðŸ–¥ï¸ ADMIN PANEL DEPLOY (Render)

### Step 1 â€” GitHub Private Repo banao
```
Naam: synex-admin (PRIVATE!)
synex-admin/ folder ki saari files upload karo
```

### Step 2 â€” Render Deploy
```
render.com â†’ New â†’ Web Service
â†’ GitHub repo connect
â†’ Build: npm install && npm run build  
â†’ Start: npx serve -s build -l 3000
â†’ Deploy!
```

### Step 3 â€” URL milega
```
https://synex-admin.onrender.com
â†’ Apne phone mein bookmark karo
â†’ Admin email se login karo
```

---

## ðŸ“± FCM Notifications Setup

Admin panel se notification bhejne ke liye:
```
Admin Panel â†’ Users â†’ Kisi user ke saamne ðŸ”” Notif
Ya
Admin Panel â†’ Users â†’ "Send to All" button
```

Phone pe automatically notification aayegi!

---

## ðŸŽ¯ Features List

### User App (Flutter):
- âœ… Splash screen with animation
- âœ… Login / Signup / Google Sign In  
- âœ… Home â€” All tournaments
- âœ… My Matches â€” Room ID + Ad-gated Password
- âœ… Wallet â€” Add money, Withdraw
- âœ… Spin Wheel â€” S$ Cash + Tickets + Synex Points
- âœ… Profile â€” Stats, Edit, Referral code
- âœ… Push Notifications (FCM)
- âœ… Store (Coming Soon placeholder)

### Admin Panel (React):
- âœ… Secure login (adminEmails collection)
- âœ… Dashboard with live stats
- âœ… Users â€” Block/Unblock, Edit Balance
- âœ… Deposits â€” Approve/Reject
- âœ… Withdrawals â€” Approve/Reject
- âœ… Tournaments â€” Create/Edit/Delete + Thumbnail upload
- âœ… Room ID + Password â†’ Auto notify players
- âœ… Spin Wheel â€” Prize edit, Probability control
- âœ… Settings â€” UPI, Live stream, Support links
- âœ… Notifications â€” Send to individual or all users
