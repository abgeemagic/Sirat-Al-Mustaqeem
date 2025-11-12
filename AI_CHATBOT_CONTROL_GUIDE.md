



Your Molvi app now has **built-in server control**! You can start and stop the AI chatbot directly from within the app.



1. **Open your Molvi app** on your phone
2. **Go to the AI Chat page**
3. **Look at the top right corner** of the app bar:
   - 🟢 **Green cloud icon** = AI Server is running (real Gemini responses)
   - 🔴 **Red cloud icon** = AI Server is offline (fallback responses)
4. **Tap the play/stop button** next to the cloud icon:
   - ▶️ **Play button** = Start the AI server
   - ⏹️ **Stop button** = Stop the AI server



If the in-app control doesn't work, you can manually start the server:


1. **Double-click** `start_ai_server.bat` in your project folder
2. **Keep the window open** while using the app


```powershell
cd "e:\FlutterProjects\molvipromaxnew\lib\ChatBot\Server"
node index.js
```




- 🟢 **Green cloud** = AI server online
- 🔴 **Red cloud** = AI server offline
- ⏳ **Loading spinner** = Checking server status


- **Green banner**: "AI Server Online - Real-time responses"
- **Orange banner**: "AI Server Offline - Using fallback responses"




1. **Make sure Node.js is installed** on your computer
2. **Check if port 3000 is available** (close other apps using it)
3. **Try the manual method** as backup


- **For emulator**: URL should be `http://10.0.2.2:3000`
- **For real device**: Change URL in `ai_service.dart` to your computer's IP address



- **Keep the server running** while chatting for best experience
- **Green indicators** mean you're getting real Gemini AI responses
- **Orange/Red indicators** mean you're getting basic offline responses
- **Refresh server status** by tapping the cloud icon

Your Molvi AI Assistant is now fully integrated with easy controls! 🎉
