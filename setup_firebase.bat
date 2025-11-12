@echo off
echo ========================================
echo 🔥 Firebase Chatbot Setup Script
echo ========================================
echo.

echo 📋 Step 1: Checking if Firebase CLI is installed...
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI not found. Installing...
    npm install -g firebase-tools
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Firebase CLI. Please run as Administrator.
        pause
        exit /b 1
    )
    echo ✅ Firebase CLI installed successfully!
) else (
    echo ✅ Firebase CLI is already installed!
)

echo.
echo 📁 Step 2: Navigating to project directory...
cd /d "e:\FlutterProjects\molvipromaxnew"
if %errorlevel% neq 0 (
    echo ❌ Could not navigate to project directory.
    echo Please make sure the path is correct: e:\FlutterProjects\molvipromaxnew
    pause
    exit /b 1
)
echo ✅ In project directory: %cd%

echo.
echo 🔐 Step 3: Firebase Login
echo Opening browser for Firebase login...
firebase login
if %errorlevel% neq 0 (
    echo ❌ Firebase login failed. Please try again.
    pause
    exit /b 1
)

echo.
echo 🔧 Step 4: Initializing Firebase Functions...
echo.
echo IMPORTANT: When prompted, please select:
echo - Functions (use spacebar to select)
echo - Use existing project
echo - Select: final-9979b
echo - JavaScript
echo - No to ESLint
echo - Yes to install dependencies
echo.
pause
firebase init functions

echo.
echo 📝 Step 5: Copying function files...
if exist "functions\index.js" (
    echo ✅ Functions directory created successfully!
) else (
    echo ❌ Functions initialization may have failed.
    pause
    exit /b 1
)

echo.
echo 🔑 Step 6: Setting up API Key
echo.
echo Please enter your Gemini API Key (starts with AIza...):
set /p API_KEY="API Key: "

if "%API_KEY%"=="" (
    echo ❌ No API key provided. Exiting.
    pause
    exit /b 1
)

echo Setting Firebase config...
firebase functions:config:set gemini.api_key="%API_KEY%"
if %errorlevel% neq 0 (
    echo ❌ Failed to set API key. Please check your key and try again.
    pause
    exit /b 1
)
echo ✅ API key configured successfully!

echo.
echo 📦 Step 7: Installing dependencies...
cd functions
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies.
    pause
    exit /b 1
)
cd ..
echo ✅ Dependencies installed!

echo.
echo 🚀 Step 8: Deploying functions...
echo This may take a few minutes...
firebase deploy --only functions
if %errorlevel% neq 0 (
    echo ❌ Deployment failed. Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS! Your Firebase Functions are deployed!
echo.
echo 📋 Next Steps:
echo 1. Copy the Function URL from above
echo 2. Update lib/Ai/ai_service.dart with the new URL
echo 3. Run: flutter clean && flutter pub get
echo 4. Test your app!
echo.
echo 🎉 Your chatbot is now ready for cross-network use!
pause