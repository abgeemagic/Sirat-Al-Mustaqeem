// Test script to verify the chatbot deployment
const https = require('https');

// Test configuration
const CLOUD_FUNCTION_URL = 'https://us-central1-final-9979b.cloudfunctions.net/chatbot';
const LOCAL_SERVER_URL = 'http://192.168.236.183:3000';

// Test message
const testMessage = {
  message: "What is the importance of Salah in Islam?",
  userContext: "general Islamic guidance"
};

// Function to test an endpoint
function testEndpoint(url, name) {
  return new Promise((resolve, reject) => {
    console.log(`\n🧪 Testing ${name}...`);
    console.log(`📡 URL: ${url}`);
    
    const postData = JSON.stringify(testMessage);
    const urlObj = new URL(url);
    
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname + '/chat',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = (urlObj.protocol === 'https:' ? https : require('http')).request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log(`📊 Status: ${res.statusCode}`);
        if (res.statusCode === 200) {
          try {
            const response = JSON.parse(data);
            console.log(`✅ ${name} - SUCCESS`);
            console.log(`💬 Response: ${response.text?.substring(0, 100)}...`);
            resolve({ success: true, response: response.text });
          } catch (e) {
            console.log(`❌ ${name} - JSON Parse Error:`, e.message);
            resolve({ success: false, error: 'Invalid JSON response' });
          }
        } else {
          console.log(`❌ ${name} - HTTP Error: ${res.statusCode}`);
          console.log(`📄 Response: ${data}`);
          resolve({ success: false, error: `HTTP ${res.statusCode}` });
        }
      });
    });

    req.on('error', (e) => {
      console.log(`❌ ${name} - Network Error:`, e.message);
      resolve({ success: false, error: e.message });
    });

    req.setTimeout(10000, () => {
      console.log(`⏰ ${name} - Timeout`);
      req.destroy();
      resolve({ success: false, error: 'Timeout' });
    });

    req.write(postData);
    req.end();
  });
}

// Function to test health endpoint
function testHealth(url, name) {
  return new Promise((resolve, reject) => {
    console.log(`\n🏥 Testing ${name} Health Check...`);
    
    const urlObj = new URL(url);
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
      path: urlObj.pathname + '/health',
      method: 'GET'
    };

    const req = (urlObj.protocol === 'https:' ? https : require('http')).request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode === 200) {
          console.log(`✅ ${name} Health - OK`);
          resolve({ success: true });
        } else {
          console.log(`❌ ${name} Health - Failed: ${res.statusCode}`);
          resolve({ success: false });
        }
      });
    });

    req.on('error', (e) => {
      console.log(`❌ ${name} Health - Error:`, e.message);
      resolve({ success: false });
    });

    req.setTimeout(5000, () => {
      req.destroy();
      resolve({ success: false });
    });

    req.end();
  });
}

// Main test function
async function runTests() {
  console.log('🚀 Starting Chatbot Deployment Tests');
  console.log('=====================================');
  
  // Test health endpoints first
  const cloudHealth = await testHealth(CLOUD_FUNCTION_URL, 'Cloud Function');
  const localHealth = await testHealth(LOCAL_SERVER_URL, 'Local Server');
  
  // Test chat endpoints
  const cloudTest = await testEndpoint(CLOUD_FUNCTION_URL, 'Cloud Function');
  const localTest = await testEndpoint(LOCAL_SERVER_URL, 'Local Server');
  
  // Summary
  console.log('\n📋 TEST SUMMARY');
  console.log('================');
  console.log(`🌐 Cloud Function Health: ${cloudHealth.success ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`🌐 Cloud Function Chat: ${cloudTest.success ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`🏠 Local Server Health: ${localHealth.success ? '✅ PASS' : '❌ FAIL'}`);
  console.log(`🏠 Local Server Chat: ${localTest.success ? '✅ PASS' : '❌ FAIL'}`);
  
  console.log('\n💡 RECOMMENDATIONS');
  console.log('==================');
  
  if (cloudTest.success) {
    console.log('✅ Cloud Function is working! Your app can work across different networks.');
    console.log('🎯 Users can access the chatbot from anywhere with internet.');
  } else {
    console.log('❌ Cloud Function needs attention. Check:');
    console.log('   - Firebase Functions deployment');
    console.log('   - Gemini API key configuration');
    console.log('   - Function URL in ai_service.dart');
  }
  
  if (localTest.success) {
    console.log('✅ Local Server is working for same-network access.');
  } else {
    console.log('⚠️  Local Server is not running (this is OK if using Cloud Function).');
  }
  
  console.log('\n🎉 Test completed!');
}

// Run the tests
runTests().catch(console.error);