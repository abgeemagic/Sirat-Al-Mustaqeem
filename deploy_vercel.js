// Vercel Deployment Script for ChatBot Server
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Vercel Deployment Script for Islamic ChatBot');
console.log('================================================\n');

// Check if Vercel CLI is installed
try {
  execSync('vercel --version', { stdio: 'pipe' });
  console.log('✅ Vercel CLI is installed');
} catch (error) {
  console.log('❌ Vercel CLI not found. Installing...');
  try {
    execSync('npm install -g vercel', { stdio: 'inherit' });
    console.log('✅ Vercel CLI installed successfully');
  } catch (installError) {
    console.error('❌ Failed to install Vercel CLI. Please install manually:');
    console.error('   npm install -g vercel');
    process.exit(1);
  }
}

// Define paths
const serverPath = path.join(__dirname, 'lib', 'ChatBot', 'Server');
const vercelJsonPath = path.join(serverPath, 'vercel.json');

console.log(`\n📂 Working in directory: ${serverPath}`);

// Check if server directory exists
if (!fs.existsSync(serverPath)) {
  console.error('❌ Server directory not found. Please check your project structure.');
  process.exit(1);
}

// Check if vercel.json exists, if not create it
if (!fs.existsSync(vercelJsonPath)) {
  console.log('📝 Creating vercel.json configuration...');
  const vercelConfig = {
    "version": 2,
    "builds": [
      {
        "src": "*.js",
        "use": "@vercel/node"
      }
    ],
    "routes": [
      {
        "src": "/(.*)",
        "dest": "/index.js"
      }
    ]
  };
  
  fs.writeFileSync(vercelJsonPath, JSON.stringify(vercelConfig, null, 2));
  console.log('✅ vercel.json created');
}

// Login to Vercel (if not already logged in)
try {
  console.log('\n🔐 Checking Vercel login status...');
  execSync('vercel whoami', { stdio: 'pipe' });
  console.log('✅ Already logged in to Vercel');
} catch (error) {
  console.log('🔐 Please log in to Vercel:');
  try {
    execSync('vercel login', { stdio: 'inherit' });
    console.log('✅ Logged in successfully');
  } catch (loginError) {
    console.error('❌ Failed to log in to Vercel');
    process.exit(1);
  }
}

// Deploy to Vercel
console.log('\n🚀 Deploying to Vercel...');
console.log('This may take a few minutes...\n');

try {
  // Change to server directory and deploy
  const deployCommand = `cd "${serverPath}" && vercel --prod --confirm`;
  const output = execSync(deployCommand, { stdio: 'pipe' });
  
  const outputString = output.toString();
  console.log(outputString);
  
  // Extract the deployment URL
  const urlMatch = outputString.match(/https:\/\/[^\s]+\.vercel\.app/g);
  if (urlMatch) {
    const deployUrl = urlMatch[0];
    console.log('\n✅ Deployment successful!');
    console.log(`🌐 Your chatbot is now available at: ${deployUrl}`);
    console.log('\n📝 Next steps:');
    console.log('1. Update lib/Ai/ai_service.dart with this URL:');
    console.log(`   static const String _baseUrl = '${deployUrl}';`);
    console.log('2. Run: flutter clean && flutter pub get');
    console.log('3. Test your app!');
    
    // Save to a file for reference
    const deploymentInfo = {
      url: deployUrl,
      deployedAt: new Date().toISOString(),
      platform: 'Vercel'
    };
    
    fs.writeFileSync(
      path.join(__dirname, 'vercel_deployment_info.json'),
      JSON.stringify(deploymentInfo, null, 2)
    );
    
    console.log('\n💾 Deployment info saved to vercel_deployment_info.json');
  } else {
    console.log('\n⚠️  Deployment completed but URL not found in output.');
    console.log('Please check the Vercel dashboard for your deployment URL.');
  }
} catch (error) {
  console.error('\n❌ Deployment failed:');
  console.error(error.message);
  console.log('\n🔧 Troubleshooting:');
  console.log('1. Check your internet connection');
  console.log('2. Ensure you have a Vercel account');
  console.log('3. Try running manually: cd lib/ChatBot/Server && vercel --prod');
  process.exit(1);
}

console.log('\n🎉 Vercel deployment process completed!');