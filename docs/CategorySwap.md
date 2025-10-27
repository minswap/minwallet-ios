# Requirements Details

## Swap 
- ### Market Orders

---

### Market Orders

* **Functional Requirements**

  * **Overview:** The Swap feature allows users to exchange one cryptocurrency for another directly using the Minswap DEX with the Market Order type.

  * **Features:**

      * **Swap Modal**

          * **Description:** Allows users to select tokens and execute the swap.

          * **Functionality:**

              * **You Pay Section:**

                  * Select token and amount to pay.

                  * Use "Half" and "Max" buttons for quick amount selection.

                  * Display current balance of the selected token.

              * **You Receive Section:**

                  * Select token and view estimated amount to receive.

              * **Order Information:**

                  * **Fields:**

                      * Minimum Receive: The minimum output users can receive.

                      * Slippage Tolerance: The value of slippage tolerance in order settings.

                      * Price Impact: The percentage indicating the potential effect the swap might have on the pool's price. A higher percentage suggests a more significant impact.

                      * Trading Fee: The fee that goes to liquidity providers as a trading fee and protocol fee.

                      * Batcher Fee: The fee paid for the service of the off-chain Laminar batcher to process transactions.

                      * Deposit ADA: The ADA amount held as minimum UTxO ADA, which will be returned when orders are processed or canceled.

              * **Swap Button:** Once all inputs are valid, users click “Swap” to proceed with signing the transaction.

              * **Password Input:** Users must enter their spending password to sign and confirm the transaction. After entering the password, they click “Sign,” and the transaction is submitted to the network for processing.

      * **Select Token Modal**

          * **Description:** Displays a searchable list of available tokens on Minswap.

          * **Functionality:**

              * Search bar for finding specific tokens.

              * Displays a list of tokens as results based on input entered in the search bar.

      * **Swap Settings**

          * **Description:** Provides settings to customize swap parameters.

          * **Options:**

              * Slippage Tolerance: Set predefined (0.1%, 0.5%, 1%, 2%) or custom slippage percentages up to 300%.

* **Non-Functional Requirements**

    - **Performance:** Ensure fast response times for token selection and swap execution.

    - **Usability:** Provide an intuitive interface that is easy to navigate and understand.

    - **Security:** Ensure secure handling of transactions and user data.

    - **Error Handling:**
        - Insufficient Balance: If users do not have enough balance to complete the swap, display an error message: "Insufficient balance."
        - Swap with Spent UTxO: If users attempt to swap with spent UTxO, display an error message: "UTxO not found."

--- 
