# Krishi Connect - Setup Guide

## Quick Start (Android Phone Only — No PC Needed)

This project builds entirely via **GitHub Actions** — no PC, no local Flutter SDK, no Android Studio.

**Minimum path to a working APK:** Firebase setup (Step 1) → seed data (Step 2) → add one secret (Step 3) → run the build (Step 4) → install (Step 5).

Release signing with a keystore is **optional** and can be added later.

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

## Step 3: Add GitHub Repository Secrets

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### Required (only one)

| Secret Name | Value |
|---|---|
| `GOOGLE_SERVICES_JSON` | The **full contents** of the `google-services.json` you downloaded from Firebase — including the outer `{` and `}` |

That's the minimum. With just this secret the build succeeds and produces a **debug-signed APK** you can install on your own phone.

> The workflow validates this secret is present and is valid JSON, and fails with a clear message if not. The Google Services Gradle plugin cannot build without it.

### Optional (for a properly release-signed APK)

Release signing is **not required to get a working APK**. Add these four secrets only when you want a real signed release (e.g. before Play Store submission):

| Secret Name | Value |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded keystore, as a single line |
| `KEY_ALIAS` | e.g. `krishiconnect` |
| `KEY_PASSWORD` | Your key password |
| `STORE_PASSWORD` | Your keystore password |

If `KEYSTORE_BASE64` is absent, the workflow logs a warning and the release build falls back to debug signing automatically — it does **not** fail.

<details>
<summary>How to generate the keystore later (needs Java/keytool, e.g. Termux)</summary>

```bash
pkg install openjdk-17 -y

keytool -genkeypair -v \
  -keystore keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias krishiconnect \
  -storepass YOUR_PASSWORD \
  -keypass YOUR_PASSWORD \
  -dname "CN=Krishi Connect, OU=Dev, O=KrishiConnect, L=City, S=State, C=IN"

# Encode to a single line for the GitHub secret
base64 keystore.jks | tr -d '\n' > keystore_base64.txt
```

**Back up `keystore.jks` somewhere safe.** Losing it means future updates can't install over an existing copy of the app.

</details>

---

## Step 4: Trigger the Build

- Push any change to `main`, OR
- Go to the **Actions** tab → **Build APK** → **Run workflow**
- Wait ~5 minutes
- Download the APK from the run's **Artifacts** section

### Debug-signed vs release-signed

| | Debug-signed (no keystore secrets) | Release-signed (keystore secrets added) |
|---|---|---|
| Installs by sideloading | ✅ Yes | ✅ Yes |
| Good for testing | ✅ Yes | ✅ Yes |
| Play Store upload | ❌ No | ✅ Yes |
| Consistent update key | ❌ No | ✅ Yes |

To install a debug-signed APK you may need to enable **Install unknown apps** for your browser or file manager in Android settings.

---

## Step 5: Install APK

1. Go to GitHub **Actions** → the completed workflow run
2. Scroll to the **Artifacts** section
3. Download `krishi-connect-release.zip`
4. Extract it and install the APK on your Android phone
5. Log in as admin: use the **Email** tab with `admin@krishiconnect.app` and the password you set in Firebase

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
