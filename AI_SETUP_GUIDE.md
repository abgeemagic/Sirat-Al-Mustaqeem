





Navigate to your ChatBot server directory and start it:

```bash
cd lib/ChatBot/Server
npm install  
node index.js
```

Your server should start on port 3000 and display: "listening on port 3000"



Make sure your `.env` file in `lib/ChatBot/Server/` contains your Gemini API key:

```
API_KEY=your_gemini_api_key_here
```



- If using Android emulator: The app is configured to use `http://10.0.2.2:3000`
- If using real device: Update `_baseUrl` in `lib/ai_service.dart` to your computer's IP address (e.g., `http://192.168.1.100:3000`)



For production, deploy your backend to a service like:
- Vercel (already configured in your project)
- Railway
- Heroku
- DigitalOcean

Then update `_baseUrl` in `ai_service.dart` to your deployed URL.




- **Android Emulator**: `http://10.0.2.2:3000` ✅ (currently configured)
- **iOS Simulator**: `http://localhost:3000`
- **Real Device**: `http://YOUR_COMPUTER_IP:3000`


- Update `_baseUrl` to your deployed backend URL



1. Start your backend server
2. Run your Flutter app
3. Open the AI Assistant page
4. Try asking: "What is Salah?" or "Tell me about Ramadan"



- ✅ Real-time AI responses powered by Google Gemini
- ✅ Islamic context and Quranic references
- ✅ Offline fallback responses
- ✅ Professional chat interface
- ✅ Arabic text support
- ✅ Loading indicators
- ✅ Error handling




1. Check if your backend server is running
2. Verify your Gemini API key in the `.env` file
3. Check network connectivity
4. Look at Flutter console for error messages


- **Network Error**: Update `_baseUrl` with correct IP/URL
- **API Key Error**: Verify your Gemini API key
- **CORS Error**: Backend is configured to allow mobile requests

Your Molvi AI Assistant is now ready to provide Islamic guidance! 🕌
