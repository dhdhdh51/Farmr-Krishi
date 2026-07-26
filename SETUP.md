# Krishi Connect - Setup Guide

## Quick Start (For Android Phone / Termux Users)

This project is designed to be built entirely via **GitHub Actions** — no PC or local Flutter SDK needed. Follow these steps:

---

## Step 1: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project: **"KrishiConnect"** (or any name)
3. Add an Android app:
   - Package name: `com.krishiconnect.app`
   - App nickname: Krishi Connect
   - Skip SHA-1 for now (needed later for phone auth)
4. Download the `google-services.json` file
5. **Enable Authentication:**
   - Go to Authentication → Sign-in method
   - Enable **Email/Password**
   - (Optional) Enable Phone if you want OTP later
6. **Enable Cloud Firestore:**
   - Go to Firestore Database → Create database
   - Start in **test mode** (we'll secure rules later)
   - Choose nearest region (asia-south1 for India)

---

## Step 2: Create Admin Account in Firebase

1. Go to Firebase Console → Authentication → Users
2. Click "Add user"
3. Enter admin email (e.g., `admin@krishiconnect.app`) and a strong password
4. Note the UID that Firebase generates
5. Go to Firestore → Create collection `users`
6. Add a document with ID = the admin UID from step 4:
   ```
   {
     "name": "Admin",
     "phone": "0000000000",
     "email": "admin@krishiconnect.app",
     "role": "admin",
     "pin": "123456",
     "isApproved": true,
     "createdAt": <server timestamp>
   }
   ```
7. Create `rates/current` document:
   ```
   {
     "pricePerJutayi": 500,
     "pricePerBighaTractor": 200,
     "pricePerHourWater": 100,
     "pricePerBighaWater": 150
   }
   ```
8. Create `settings/auth` document:
   ```
   {
     "otpRequired": false,
     "otpForPhoneLogin": false
   }
   ```

---

## Step 3: Generate a Signing Keystore

On any system with Java/keytool (or use Termux):

```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias krishiconnect
```

Enter a password when prompted (remember it!). This creates `keystore.jks`.

---

## Step 4: Add GitHub Repository Secrets

Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

| Secret Name | Value |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded keystore. Run: `base64 -i keystore.jks` (copy the output) |
| `KEY_ALIAS` | `krishiconnect` (or whatever you used with keytool) |
| `KEY_PASSWORD` | The password you entered during keytool |
| `STORE_PASSWORD` | Same password (or different if you set differently) |
| `GOOGLE_SERVICES_JSON` | Full contents of `google-services.json` file |

### How to base64 encode in Termux:
```bash
base64 keystore.jks | tr -d '\n'
```
Copy the entire output and paste as `KEYSTORE_BASE64` secret.

### How to get google-services.json content:
```bash
cat google-services.json
```
Copy the entire JSON and paste as `GOOGLE_SERVICES_JSON` secret.

---

## Step 5: Trigger the Build

- Push any change to `main` branch, OR
- Go to Actions tab → "Build Signed APK" → "Run workflow"
- Wait ~5 minutes for the build to complete
- Download the APK from the workflow's **Artifacts** section

---

## Step 6: Install APK

1. Go to GitHub Actions → completed workflow run
2. Scroll to "Artifacts" section
3. Download `krishi-connect-release.zip`
4. Extract and install the APK on your Android phone

---

## Firestore Security Rules (Apply after testing)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write own doc
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Rates - anyone can read, only admin can write
    match /rates/{doc} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Settings - anyone can read, only admin can write
    match /settings/{doc} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Resources - anyone can read, admin can write
    match /resources/{type}/items/{itemId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Connections - authenticated users
    match /connections/{connectionId} {
      allow read, write: if request.auth != null;
    }

    // Jobs - authenticated users
    match /jobs_tractor/{jobId} {
      allow read, write: if request.auth != null;
    }
    match /jobs_tubewell/{jobId} {
      allow read, write: if request.auth != null;
    }

    // Payments - authenticated users
    match /payments/{paymentId} {
      allow read, write: if request.auth != null;
    }

    // Expenses - authenticated users
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user_model.dart
│   ├── tractor_model.dart
│   ├── tubewell_model.dart
│   ├── connection_model.dart
│   ├── job_tractor_model.dart
│   ├── job_tubewell_model.dart
│   ├── payment_model.dart
│   ├── expense_model.dart
│   └── rate_model.dart
├── services/                    # Business logic & API
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   └── rate_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── role_selection_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   ├── pricing_screen.dart
│   │   ├── resource_management_screen.dart
│   │   ├── revenue_report_screen.dart
│   │   ├── all_logs_screen.dart
│   │   ├── user_management_screen.dart
│   │   └── auth_settings_screen.dart
│   ├── farmer/
│   │   ├── farmer_home_screen.dart
│   │   ├── book_tractor_screen.dart
│   │   ├── book_tubewell_screen.dart
│   │   ├── farmer_history_screen.dart
│   │   ├── search_connect_screen.dart
│   │   └── my_connections_screen.dart
│   ├── tractor_owner/
│   │   ├── tractor_owner_home_screen.dart
│   │   └── log_tractor_job_screen.dart
│   ├── tubewell_owner/
│   │   ├── tubewell_owner_home_screen.dart
│   │   └── water_session_screen.dart
│   └── common/
│       ├── profile_screen.dart
│       ├── payment_history_screen.dart
│       └── add_expense_screen.dart
└── utils/
    ├── constants.dart
    └── theme.dart
```

---

## Key Features Implemented

- **4 Roles**: Admin (hidden), Farmer, Tractor Owner, Tubewell Owner
- **Auth**: Phone+PIN login (no OTP), Email+Password, Admin OTP toggle
- **Farmer**: Search/connect owners, book tractor/tubewell, view history
- **Tractor Owner**: Log jobs, view earnings, track pending payments
- **Tubewell Owner**: Timer-based and bigha-based water sessions, electricity expense tracking
- **Admin**: Pricing control, resource management, revenue reports, user approval, auth settings
- **Payments**: Auto-created on job completion, mark paid (cash/UPI)
- **CI/CD**: GitHub Actions builds signed APK on every push to main
