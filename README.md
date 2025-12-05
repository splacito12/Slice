# CS180 Project: Slice

## Team Members
1. Rewa El Masri: relma003@ucr.edu
2. Natalie Wu: nwu039@ucr.edu
3. Samantha Placito Melendrez: splac006@ucr.edu
4. Hooman Masroor: hmasr001@ucr.edu

## Project Slice
  Slice is an end-to-end encrypted messaging app meant to allow people to engage in conversations privately with their friends or other people in a group chat. It allows them to message people through different devices, such as iOS, a browser, or Android.

## How to Implement
  1. First, you would need to obtain the HTTPS link from our GitHub. You can do this by clicking the green < > Code button and then opening or installing VSCode. From there, you will need to install the Flutter extension by going to the extension tab and searching for Flutter. After you have installed the Flutter extension, you will need to open the terminal and copy the following:
  
    git clone https://github.com/splacito12/Slice.git
  
  2. Once you have, you press **ENTER** to create a local clone on your device. After that is completed, you will need to select open to open it on your current window. If you want to **open** it in a new window, you will need to press **open in a new window.**
  
  3. The next step in our installation process is that you either continue using your current terminal or open a new one. Either or doesn’t affect the outcome.

  4. You can also download a compatible emulator for your device. For example, if you are using a Windows computer, you can install an Android emulator at the following website:
     
         https://developer.android.com/studio
      - There, you can follow the steps on the website below on how to set up the emulator on VSCode:
        
            https://medium.com/@bosctechlabs/code-of-how-to-set-up-an-emulator-for-vscode-updated-ad4365c0559b
        
      - Of course, this is only optional. You don’t have to have an emulator to be able to run our app, but it is recommended for a better experience. 

  6. Next, you will need to call the slice directory by doing the following command in the terminal:
     
         cd slice
    
      - Because this project uses Firebase for authentication and encrypted messaging, anyone who clones the repository must create their own Firebase project and connect it using the FlutterFire CLI. Firebase configuration files cannot be included in the repository for security reasons, so running flutterfire configure is required to generate your own **firebase_options.dart** file before the app can run.

  8. After that, you will need to configure Firebase and install all of the dependencies for our app by running the following command:

         flutterfire configure
    
      - This links the project to a Firebase app and generates the **firebase_options.dart** file that is used by our app. And then, after that is done, you will paste the following:

            flutter pub get
    
  7. Once that is done, you can finally run the program by using the following command:
     
          flutter run

  9. If you aren’t in the correct directory, it will not work. Now, depending on whether you are using an emulator or not, you will be given two options:
      
      - Without emulator:
          - If you are on a Windows computer, you will be prompted to either open the app on Windows or in your browser. Click the associated letter or number for your preferred choice. After that, the application will open

      - With emulator:
          - Flutter will open the emulator and run the application. Depending on your internet or the device, it can take a while.
      

  9. After the application is now either on your browser or your choice of emulator, the app will open, and you will see our login page, where, if you already have an existing account, you can log in. There is also a signup page. You can register an account by pressing the sign-up button and inputting your information. Once an account is created, you will get a verification email and be taken to the homepage of our app. There, you can add friends by pressing the add friend icon in the upper right corner, searching them up by their email. If they accept your friend request, you can start chatting with them immediately.


## UML Diagram
<img width="727" height="492" alt="Screenshot 2025-12-04 at 7 15 31 PM" src="https://github.com/user-attachments/assets/e856f6e8-9093-4880-ba48-c377c4c3c7db" />

## Use Case Diagram
<img width="536" height="590" alt="Screenshot 2025-12-04 at 7 20 56 PM" src="https://github.com/user-attachments/assets/fded0e3e-c536-4577-99ce-b44b914052d1" />
