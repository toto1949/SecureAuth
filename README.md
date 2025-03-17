# *SecureAuth*

SecureAuth is a **SwiftUI-based authentication app** that allows users to enter their email and verify their identity via a **Flask backend**. The app dynamically connects to the correct server URL based on whether it's running on a **simulator or a physical device**.

## **Table of Contents**
- [Technologies Used](#technologies-used)  
- [Installation](#installation)  
- [Project Structure](#project-structure)  
- [Backend API](#backend-api)  
- [Server Configuration](#server-configuration)  
- [Usage](#usage)  
- [Video Demonstration](#video-demonstration)  
- [Screenshots](#screenshots)  
- [Future Enhancements](#future-enhancements)  
- [Contributing](#contributing)  
- [License](#license)  

---

## **Technologies Used**
### **Frontend (iOS)**
- Swift  
- SwiftUI  
- Combine (for state management)  
- URLSession (for network requests)  

### **Backend**
- Python  
- Flask  
- JSON for data handling  

---

## **Installation**
### **1. Clone the repository**
```sh
git clone https://github.com/toto1949/SecureAuth.git
cd SecureAuth
```

### **2. Setup the iOS project**
1. Open `SecureAuth.xcodeproj` in Xcode.  
2. Ensure you have **Xcode 15+** installed.  
3. Build & run the project using **Command + R**.  

### **3. Setup the Flask Backend**
1. Navigate to the backend folder:
   ```sh
   cd backend
   ```
2. Create a virtual environment (optional but recommended):
   ```sh
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```sh
   pip3 install flask
   ```
4. Run the Flask server:
   ```sh
   python3 back-flask.py
   ```
5. The server should now be running at:
   - **Simulator:** `http://127.0.0.1:5000`
   - **Physical Device:** `http://<YOUR_LOCAL_IP>:5000`

---

## **Project Structure**
```
SecureAuth/
│── SecureAuth/                  
│   ├── SecureAuthApp.swift           # Entry point of the app
│   ├── ContentView.swift             # Main UI screen
│   │
│   ├── Views/                        # UI components
│   │   ├── ContentView.swift         # Main app view
│   │
│   ├── ViewModel/                    # ViewModel layer
│   │   ├── AuthenticationViewModel.swift  # Handles authentication logic
│   │
│   ├── SDK/                           # Third-party or custom SDKs
│   │   ├── BiometricAuthenticator.swift 
│   │   ├── BiometricAuthSDK.swift     
│   │   ├── NetworkService.swift       # Handles API requests
│   │
│   ├── Constants/                         # Utility functions
│   │   ├── BiometricError.swift/    # Constants for biometric errors             
│   │
│   │
│   ├── Assets.xcassets                # App assets
│
│── backend/                            # Flask backend
│   ├── back-flask.py                   # Main Flask app
│
└── README.md                           # Main project documentation

```

---

## **Backend API**
The Flask backend handles **token validation**.

### **1. Validate Token**
- **Endpoint:** `POST /api/validate-token`  
- **Request Format (JSON):**
  ```json
  {
    "token": "{\"userId\": \"12345\", \"deviceId\": \"abc123\", \"expiryDate\": 1718900000}"
  }
  ```
- **Response (Success - 200 OK):**
  ```json
  {
    "message": "Token received",
    "token": {
      "userId": "12345",
      "deviceId": "abc123",
      "expiryDate": 1718900000
    }
  }
  ```
- **Response (Error - 400 Bad Request):**
  ```json
  {
    "error": "Invalid token format"
  }
  ```

---

## **Server Configuration**
Since an iOS **simulator** and a **physical device** need different backend URLs, `NetworkManager.swift` dynamically selects the correct **server URL**.

### **Simulator (localhost)**
If you're running the app on a **simulator**, the backend URL should be:
```swift
let serverURL = "http://127.0.0.1:5000"
```

### **Physical Device**
For a **physical iPhone**, use your local network IP:
```swift
let serverURL = "http://192.168.X.X:5000"
```
Find your local IP:
```sh
ifconfig | grep "inet " | grep -v 127.0.0.1
```
Or on Windows:
```sh
ipconfig
```

### **How to Update the URL in Swift**
Modify `NetworkManager.swift`:
```swift
import Foundation

struct NetworkManager {
    static let isSimulator = TARGET_OS_SIMULATOR != 0
    static let serverURL = isSimulator ? "http://127.0.0.1:5000" : "http://192.168.X.X:5000"
}
```

---

## **Usage**
### **Running the iOS App**
1. Open **Xcode**  
2. Select an iPhone **simulator** or **physical device**  
3. Click **Run (▶️)** to launch the app  

### **Running the Flask Backend**
1. Start the server:
   ```sh
   python back-flask.py
   ```
2. The API will be available at:
   - **Simulator:** `http://127.0.0.1:5000`
   - **Physical Device:** `http://<YOUR_LOCAL_IP>:5000`

### **Testing API with cURL**
```sh
curl -X POST http://127.0.0.1:5000/api/validate-token \
     -H "Content-Type: application/json" \
     -d '{"token": "{\"userId\": \"12345\", \"deviceId\": \"abc123\", \"expiryDate\": 1718900000}"}'
```

---

## **Video Demonstration**
📹 A video demonstration of the app in action will be available at:  
**[Add Video Link Here]**  

---

## **Screenshots**
| Login Screen | Success Message |
|--------------|-----------------|
| ![Login](./SecureAuth/Screenshots/loginscreen.jpeg) | ![Success](./SecureAuth/Screenshots/success.jpeg) |


## **License**
This project is licensed under the **MIT License**.  