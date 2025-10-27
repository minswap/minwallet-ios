# Requirements Details

## Settings
* ### Change password
* ### Disconnect
* ### App Settings

---

### Change Password

* **Functional Requirements**

  * **Overview:** The Change Password feature allows users to securely update their account password. It includes input fields for the old password and new password, as well as confirmation of the new password.

  * **Feature Flow:**

      * **Change Password Form**

          * **Description:** Provide a form for users to change their password.

          * **Fields:**

              * Old Password: Input field for the current password.

              * New Password: Input field for the new password.

              * Confirm New Password: Input field to confirm the new password.

      * **Password Validation**

          * **Description:** Ensure that the new password meets security requirements.

          * **Validation Criteria:**

              * Minimum length (e.g., 8 characters).

              * Must include a mix of uppercase, lowercase, numbers, and special characters.

              * New password must not match the old password.

      * **Confirmation Screen**

          * **Description:** Display a confirmation message upon successful password change.

          * **Content:**

              * Message: "Your password has been successfully changed."

              * Action: "Got it" button to acknowledge and return to the previous screen.

* **Non-Functional Requirements:**

    * **Security**

        * Ensure all data transmissions are encrypted.

        * Implement rate limiting to prevent brute force attacks.

    * **Usability**

        * Provide clear instructions and feedback on errors.

    * **Performance**

        * The process should be completed within a few seconds under normal conditions.

    * **Error Handling**

        * Incorrect Old Password: If users enter an incorrect old password, display an error message: "The old password is incorrect."

        * Password Mismatch: If new password and confirmation do not match, show an alert: "New passwords do not match."

        * Weak New Password: If the new password does not meet security criteria, display feedback: “Password needs to be at least 12 characters, with at least one capital letter, one digit, and one special character.”

        * Breached New Password: If the new password is breached, display an error "This password has been breached; please use a different password."

---

### Disconnect

* **Functional Requirements**

  * **Overview:** The Disconnect feature allows users to securely disconnect their wallet from the Minswap dApp, ensuring no further transactions can be made until reconnection.

  * **Feature Flow:**

      * **Disconnect Wallet**

          * **Description:** Provide a button for users to disconnect their wallet from the dApp.

          * **Functionality:**

              * Display a confirmation dialog before disconnecting.

              * Ensure all active sessions are terminated.

      * **Confirmation Dialog**

          * **Description:** Prompt users to confirm their decision to disconnect.

          * **Content:**

              * Message: "Are you sure you want to disconnect your wallet?"

              * Options: "Cancel" and "Confirm" buttons.

      * **Session Termination**

          * **Description:** End all active sessions related to the user's wallet.

          * **Functionality:**

              * Clear any session data stored locally.

              * Ensure no residual connections remain active.

* **Non-Functional Requirements**

    * **Security**

        * Ensure secure handling of session termination to prevent unauthorized access.

    * **Usability**

        * Provide clear feedback and instructions throughout the disconnection process.

    * **Performance**

        * The disconnection process should complete swiftly, ideally within a few seconds.

* **Error Handling**

    - Disconnection Failure: If an error occurs while trying to disconnect the wallet, display an error message: "Failed to disconnect. Please try again."

---

### App Settings

* **Functional Requirements**

  * **Overview:** The App Settings feature allows users to customize their experience by adjusting language, currency, notifications, biometric settings, appearance, and accessing app information.

  * **Features:**

      - **Language Selection**

          - **Description:** Allow users to choose their preferred language.

          - **Functionality:**

              - The default language is EN-US.

              - Display a list of available languages.

              - Highlight the currently selected language.

      - **Currency Selection**

          - **Description:** Enable users to switch their preferred currency for display between ADA and USD.

          - **Functionality:**

              - Display a list of supported currencies.

              - Show the current selection.

      - **Notifications**

          - **Description:** Toggle notifications on or off.

          - **Functionality:** Simple toggle switch to enable or disable notifications.

      - **Biometric Authentication**

          - **Description:** Enable or disable Face ID/Fingerprint for app access.

          - **Functionality:**

              - Toggle switch for biometric settings.

              - Toggle ON will allow users to sign transactions using biometrics instead of inputting a password.

      - **Appearance Settings**

          - **Description:** Allow users to select the app's appearance mode.

          - Options:

              - Default, Dark, and Light modes.

              - Explanation of each mode's impact on the app's theme.

      - **About Section**

          - **Description:** Provide information about the app and access support.

          - Content:

              - Privacy Policy

              - Terms of Service

              - Get Help

              - Share Feedback

              - Links

* **Non-Functional Requirements**

    - Performance:

        - Ensure quick response times when changing settings.

    - Usability:

        - Provide an intuitive layout that is easy to navigate and understand.

    - Security:

        - Ensure secure handling of user settings and data.