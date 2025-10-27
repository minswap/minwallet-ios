# Requirements Details

## Wallet
* ### Create/Restore Wallet
* ### Send/Receive Tokens
* ### Order History

---

### Create Wallet

* **Functional Requirements**

    * **Overview:** This feature allows users to create a secure cryptocurrency wallet to manage their assets on
      Minswap. The wallet creation process will guide users through generating a seed phrase, setting up a password, and
      securing their account.

    * **Feature Flow:**

        * Provide security tips.

        * Generate and secure a 24-word seed phrase.

        * Re-enter the seed phrase to ensure it is recorded correctly.

        * Name the wallet and create a spending password.

        * Receive confirmation that their wallet has been successfully created.

* **Non-Functional Requirements**

    * **Security:** Seed phrases are generated locally and never stored or transmitted. Passwords must be hashed before
      storage and should follow best encryption practices.

    * **Performance:** The wallet generation process must not exceed 5 seconds.

    * **Usability:** The UI should be clear and intuitive, guiding the user through each step seamlessly. Visual
      feedback should be provided on errors (e.g., incorrect seed phrase input).

    * **Error Handling:** If users enter an incorrect seed phrase during the re-input phase, an error message should
      inform them to try again. If users fail to create a spending password, the system should prompt them to ensure all
      fields are filled correctly.

---

### Restore Wallet

* **Functional Requirements**

    * **Overview:** This feature offers users a multi-step process to restore the wallet via their 24-word seed phrase.

    * **Feature Flow:**

        * Provide the “Seed Phrase” option to let users acknowledge the restoring method.

        * Provide a textbox for users to input the seed phrase.

        * Name the wallet and create a spending password.

        * Receive confirmation that their wallet has been successfully created.

* **Non-Functional Requirements**

    * **Security:** Seed phrases must be handled locally, with no transmission of sensitive data. Passwords must be
      hashed before storage and should follow best encryption practices.

    * **Performance:** The wallet restoration process must not exceed 5 seconds.

    * **Usability:** The user interface should be clear, with progress feedback provided at each step. Error handling
      should be in place for incorrect seed phrases.

    * **Error Handling:** If users input an incorrect seed phrase, an error message will prompt them to retry.

---

### Send Tokens

* **Functional Requirements**

    * **Overview:** This feature allows users to securely transfer cryptocurrency tokens from their wallet to another
      address. The process involves the following steps:

    * **Feature Flow:**

        * **Select Tokens to Send**

            * **Description:** Users choose the amount of tokens they want to send.

            * **Functionality:**

                - Input Amount: Users can specify the amount of tokens they want to send by either manually entering a
                  value or clicking the “Max” button to send their entire balance.

                - Select Token: Users can select which token they wish to send from their wallet. The default option is
                  ADA, but other tokens such as MIN or SNEK can be added.

                - Add Token: If users wish to send multiple types of tokens in one transaction, they can click “Add
                  Token” to include additional tokens.

                - After confirming the token and amount, users click “Next” to proceed.

        * **Enter Wallet Address**

            * **Description:** Users enter the recipient’s wallet address.

            * **Functionality:**

                - Input Field: Users can either manually type or paste the recipient's wallet address. They can also use
                  an ADAHandle for easier address management.

                - After entering a valid address/AdaHandle, users click “Next” to proceed to the confirmation step.

        * **Confirmation of Details**

            * **Description:** This third step is a review of transaction details before it is sent.

            * **Functionality:**

                - Transaction Breakdown: This screen displays the total amount of tokens being sent, broken down by
                  type (ADA, MIN, LIQ, etc.).

                - Recipient Address: The recipient’s wallet address is displayed for user verification.

                - Select Best Route: The platform may offer route optimization for the transaction, ensuring the best
                  possible network fee.

                - Transaction Fees: A small fee (e.g., 0.3 ADA) may be deducted from the balance for network costs.

                - Once all details are reviewed and verified, users click “Confirm” to proceed.

        * **Signing the Transaction**

            * **Description:** The final step involves signing the transaction to authorize it.

            * **Functionality:**

                - Password Input: Users must enter their spending password to sign and confirm the transaction.

                - Once the password is entered, they click “Sign,” and the transaction is submitted to the network for
                  processing.

* **Non-Functional Requirements**

    - **Security:** User spending passwords must be encrypted when stored locally or during transmission. Only intended
      recipient's wallet addresses will be accepted and verified for each transaction, preventing unauthorized
      transfers.

    - **Performance:** The transaction should be submitted within a maximum of 5 seconds upon user confirmation. Any
      transaction signed by the user must be confirmed and broadcasted to the blockchain within one minute after
      signing.

    - **Usability:** The user interface must be simple and intuitive, allowing users to easily navigate through four
      steps of sending tokens. The list of tokens must be up-to-date with accurate metadata (token name, decimal, token
      amount). Real-time feedback for input errors (e.g., invalid wallet address or token amount) must be provided along
      with clear error messages when issues arise (e.g., failed transaction).

    - **Error Handling:** If a user enters an invalid wallet address or if an ADAHandle cannot be resolved, an error
      message will be displayed prompting them accordingly.

---

### Receive Tokens

* **Functional Requirements**

    * **Overview:** The Receive feature allows users to share their wallet address for receiving payments. It includes
      QR code generation along with options for sharing or copying the address.

    * **Features:**

        * **Display Wallet Address**

            * **Description:** Show user's wallet address in text form.

            * **Functionality:** Ensure that address is clearly visible and accurate.

        * **QR Code Generation**

            * **Description:** Generate a QR code for user's wallet address.

            * **Functionality:** Display scannable QR code representing wallet address.

        * **Share Functionality**

            * **Description:** Allow users to share their wallet address easily.

            * **Options**: Provide "Share" button that opens sharing options (e.g., email, messaging apps).

        * **Copy Address**

            * **Description:** Enable users to copy their wallet address to clipboard.

            * **Functionality**: Include "Copy" button that copies address with confirmation success message.

* **Non-Functional Requirements**

    - **Performance**: Page should load quickly with minimal delay in generating QR codes.

    - **Usability**: Interface should be intuitive with clear instructions for sharing and copying addresses.

    - **Security**: Ensure that wallet addresses are securely handled without unnecessary exposure.

    - **Error Handling**: If there’s failure in generating/displaying QR codes or copying addresses, an error message
      will appear accordingly.

---

### Order History

* **Functional Requirements**

    * **Overview:** The Orders page displays all transactions created by users on Minswap. It provides details about
      each order including status and available actions. Supported order types include Market, Limit, Stop, OCO, Partial
      Fill, Add LP, Withdraw LP, Zap In, Zap Out.

    * **Features**:

        * **Order List Display**

            - **Description**: Display list of all user orders.

            - **Fields**:

                - Token Pair: Shows trading pair (e.g., ADA/MIN).

                - Action: Type of order (e.g., Market).

                - You Paid: Amount paid by user.

                - You Receive: Amount expected back from order execution.

                - Status: Current status of order (Complete, Pending, Refunded, Cancelled).
        
        | Order types | Order Status | Batched Price | LP Fee | Limit Price | Stop Price | Minimum Receive | Batcher Fee | Deposited ADA |
        | :---- | :---- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
        | **All** | Canceled by user | \- | \- | \- | \- | \- | \- | \- |
        | Market Order | Queueing | \- | \- | \- | \- | YES | YES | YES |
        |  | Canceled by FoK | YES | \- | \- | \- | \- | \- | \- |
        |  | Completed | YES | YES | \- | \- | \- | YES | YES |
        | Limit Order | Queueing | \- | \- | YES | \- | YES | YES | YES |
        |  | Canceled by Expiry | \- | \- | YES | \- | \- | \- | \- |
        |  | Completed | YES | YES | YES | \- | \- | YES | YES |
        | Stop Order | Queueing | \- | \- | \- | YES | YES | YES | YES |
        |  | Canceled by Expiry | \- | \- | \- | YES | \- | \- | \- |
        |  | Completed | YES | YES | \- | YES | \- | YES | YES |
        | OCO Order | Queueing | \- | \- | YES | YES | YES | YES | YES |
        |  | Canceled by Expiry | \- | \- | YES | YES | \- | \- | \- |
        |  | Completed | YES | YES | YES | YES | \- | YES | YES |
        | Partial Fill | Queueing | \- | \- | \- | \- | YES | YES | YES |
        |  | Queueing and filled some | \- | \- | \- | \- | YES | YES | YES |
        |  | Completed | YES | YES | \- | \- | \- | YES | YES |
        | Add LP | Queueing | \- | \- | \- | \- | \- | YES | YES |
        |  | Completed | YES | \- | \- | \- | \- | YES | YES |
        | Withdraw LP | Queueing | \- | \- | \- | \- | \- | YES | YES |
        |  | Completed | YES | \- | \- | \- | \- | YES | YES |
        | Zap In | Queueing | \- | \- | \- | \- | YES | YES | YES |
        |  | Completed | \- | \- | \- | \- | \- | YES | YES |

        * **Filters and Search**

            * **Description**: Enable users to filter and search through their orders.

            * **Functionality**:

                - Search bar for quick lookup.

                - Filter options for sorting by status, date or token pair.

        * **Order Actions**

            * **Description**: Allow users to take actions on their orders.

            * **Actions Available:**

                * Cancel: Cancel an order that is still pending or out of price range.

                * Update: Update an order if it is out of price range to meet slippage requirements.

* **Non-Functional Requirements**

    * **Performance:** The page should load within two seconds with up to one hundred orders displayed.

    * **Usability:** The interface should be intuitive and easy to navigate.

    * **Security:** Ensure all data is securely transmitted and stored while adhering to best practices in data
      protection.

    * **Error Handling:** If there is failure in retrieving order data from server or if input yields no result then
      display error messages accordingly.
