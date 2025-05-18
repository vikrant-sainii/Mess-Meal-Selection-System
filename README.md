# Mess Meal Selection System


## Overview

The **Mess Master** project streamlines hostel mess management by integrating a user-friendly Flutter app with Firebase as backend. It offers real-time meal selection updates, secure user authentication, and dynamic data visibility for students and administrators.

This project was developed as part of the Design Thinking course (3 credits) by a diverse team of four students from different branches: Mechanical Engineering (ME), Data Science and Engineering (DSE), Electronics and Communication Engineering (ECE), and Computer Science Engineering (CSE). We divided tasks among four of us from idea to survey and from learning to implementing it.

Our team division was strategic: Gurnoor Singh from DSE conceptualized the core idea, Agampreet Kaur from ECE took charge of compiling the detailed project report, Sahil Sharma from ME led the interaction with the hostel warden and conducted student surveys, while I (Vikrant Saini), representing CSE, took on the responsibility of developing the multi-platform Flutter/Dart application.

The resulting app seamlessly runs across Android, iOS, macOS, and Windows, effectively enhancing both the dining experience for hostel residents and the operational efficiency of mess management.

---

## Features

- Real-time updates for daily meal selection  
- Intuitive admin dashboard to manage menus and users  
- Multi-platform support: Android, iOS, macOS, Windows  
- Secure user authentication using Firebase  
- Dynamic Realtime Database & Firestore integration for instant data sync  
- Easy scalability and maintainability through modular design
---

## Screenshots

### User Interface and Features

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/cb261745-0f71-4e88-b7df-3011d5f797be" alt="Student Login" width="250"/><br/>
      <em>Student Login Landing Page</em>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/930baee5-baec-46d5-90ef-da0c7498c0c1" alt="Mess Admin Login" width="250"/><br/>
      <em>Mess Admin Login Page</em>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/8f098271-30f4-44a6-9eca-b770cedce535" alt="Admin Meal Control" width="250"/><br/>
      <em>Admin Meal Control UI</em>
    </td>
  </tr>

  <!-- Spacer Row -->
  <tr><td colspan="3"><br/><br/></td></tr>

  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/2c1da5af-ee94-49b8-abb1-9af5bdae532a" alt="Student Meal Control" width="250"/><br/>
      <em>Student Meal Control UI</em>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/a12913a5-dc4e-485c-907b-d37293a55217" alt="Student UI Glimpse" width="250"/><br/>
      <em>Student UI Glimpse</em>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/d36c820d-2267-4493-a58a-8e636c8e2291" alt="Admin UI Glimpse" width="250"/><br/>
      <em>Admin UI Glimpse</em>
    </td>
  </tr>
</table>

---


## Technologies Used

| Frontend                                   | Backend                 | Database                           | Development Tools                 |
|-------------------------------------------|-------------------------|----------------------------------|----------------------------------|
| Flutter (Android, iOS, macOS, Windows)    | Firebase Authentication | Firebase Realtime Database & Firestore | VS Code, Android Studio, Xcode |

---

## How Our App Works ?

### Refer to the project poster and meet the team

<p align="center">
  <table>
    <tr>
      <td align="center">
        <img src="https://github.com/user-attachments/assets/1e2e8af7-4257-4a0d-8821-23b4eb0a3eef" alt="Project Poster" width="400"/><br/>
        <strong>Project Poster</strong>
      </td>
      <td align="center">
        <img src="https://github.com/user-attachments/assets/fd1314da-5a84-4ca5-91bd-bd007af55a91" alt="Team Photo" width="400"/><br/>
        <strong>Team Photo</strong>
      </td>
    </tr>
  </table>
</p>


### Project Report

For detailed insights and technical documentation, please refer to the comprehensive project report prepared by our team member Agampreet Kaur:
[DTII project report(1).pdf](https://github.com/user-attachments/files/20274727/DTII.project.report.1.pdf)




___

# How to Run
## 1.	Clone the repository

    git clone https://github.com/your-username/your-repo-name.git

    cd your-repo-name


## 2.	Install dependencies
Run the following command to fetch all required Flutter packages:

    flutter pub get
  

## 3.	Configure Firebase
•	Set up your Firebase project in the Firebase Console.

•	Download your platform-specific config files (GoogleService-Info.plist for iOS, google-services.json for Android).

•	Important: Do NOT commit these config files or the generated firebase_options.dart file to version control.

•	Add these files locally to your project following FlutterFire setup guides.

## 4.	Run the app
Launch the app on your preferred device or emulator:

    flutter run



___

## Notes
•	🔒 Keep your API keys and config files secure
  Never push Firebase config files or API keys to public repositories.
  
•	.gitignore is configured to block sensitive files like firebase.json, firebase_options.dart, and platform-specific config files.

•	Double-check commits before pushing to avoid exposing private data.

___


## About the Developer

I am Vikrant Saini, a Computer Science student at NIT Jalandhar (NITJ’28). This project helped me explore:

- Firebase integration  
- Real-time database management  
- UI/UX principles in mobile app development  

Alongside this project, I’ve built other applications like a Nike Shoes App UI and a WhatsApp prototype to sharpen my design and prototyping skills.

---

# LICENSE

This project is licensed under the MIT License.  
For more details, see the [MIT License](https://opensource.org/licenses/MIT).
