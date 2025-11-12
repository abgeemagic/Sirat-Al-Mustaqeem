@echo off
title Vercel Deployment Script for Islamic ChatBot

echo ========================================
echo 🚀 Vercel Deployment Script
echo ========================================
echo.

echo 📋 Step 1: Checking if Vercel CLI is installed...
vercel --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Vercel CLI not found. Installing...
    npm install -g vercel
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Vercel CLI. Please run as Administrator.
        pause
        exit /b 1
    )
    echo ✅ Vercel CLI installed successfully!
) else (
    echo ✅ Vercel CLI is already installed!
)

echo.
echo 📁 Step 2: Navigating to server directory...
cd /d "e:\FlutterProjects\molvipromaxnew\lib\ChatBot\Server"
if %errorlevel% neq 0 (
    echo ❌ Could not navigate to server directory.
    echo Please make sure the path is correct: e:\FlutterProjects\molvipromaxnew\lib\ChatBot\Server
    pause
    exit /b 1
)
echo ✅ In server directory: %cd%

echo.
echo 🔐 Step 3: Vercel Login
echo Opening browser for Vercel login...
vercel login
if %errorlevel% neq 0 (
    echo ❌ Vercel login failed. Please try again.
    pause
    exit /b 1
)

echo.
echo 🚀 Step 4: Deploying to Vercel...
echo This may take a few minutes...
echo.

vercel --prod
if %errorlevel% neq 0 (
    echo ❌ Deployment failed. Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS! Your server is deployed to Vercel!
echo.
echo 📋 Next Steps:
echo 1. Copy the deployment URL from above
echo 2. Update lib/Ai/ai_service.dart with the new URL
echo 3. Run: flutter clean && flutter pub get
echo 4. Test your app!
echo.
echo 🎉 Your chatbot is now ready for cross-network use!
echo.
echo Press any key to exit...
pause >nul