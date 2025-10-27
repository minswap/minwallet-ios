# Requirements Details

* ### Portfolio
* ### Token List
* ### Token Detail
* ### Search

---

### Portfolio

* **Functional Requirements**

    * **Overview:** The Wallet Portfolio feature provides users with a comprehensive view of their cryptocurrency
      holdings, including balances, FT token details, and NFTs.

    * **Features:**

        * **Portfolio Overview**

            * **Description:** Display the total balance and recent performance of the user's wallet.

            * **Fields:**

                * Token Address/AdaHandle

                * Total Balance: Overall value of all holdings.

                * Disclaimer Tooltip: “The data is only for your reference; there is no guarantee that the data is
                  absolutely accurate.”

                * Performance Indicator: Percentage change in portfolio value.

        * **Your Tokens**

            * **Description:** Show a detailed list of tokens in the user's portfolio.

            * **Fields:**

                * Token Name and Symbol: Displayed with icons.

                * Balance: Amount held by the user.

                * Current Price and Change: Displayed alongside each token.

        * **Your NFTs**

            * **Description:** Show a detailed list of NFTs in the user's wallet.

            * **Fields:**

                * NFT Image: Displayed with a static image; the first frame if the NFT is an animated image.

                * NFT Name: Displayed with NFT.

* **Non-Functional Requirements**

    * **Performance:** Ensure quick loading times and smooth navigation between tabs.

    * **Usability:** Provide an intuitive layout that is easy to navigate and understand.

    * **Security:** Ensure secure handling of user data and transactions.

    * **Error Handling:** If there is a failure to load portfolio data, display an error message: "Unable to load
      portfolio data. Please try again later."

---

### Token List

* **Functional Requirements**

* **Overview:** The Token List feature provides users with a view of the top tokens on Minswap DEX by default.

* **Features:**

    * **Display Token List**

        * **Description:** Show the user's wallet address in text form.

        * **Functionality:**

            * The list only appears when the wallet is not connected.

            * Ensure that the tokens are verified and sorted by TVL in descending order.

            * Each item serves as a call to action (CTA) to view more details.

        * **Fields:**

            * **Token Name:** Full name and symbol (e.g., ADA - Cardano, MIN - Minswap).

            * **Current Price:** Displayed in the relevant currency.

            * **Price Change:** Percentage change in price with visual indicators for increase or decrease.

* **Real-Time Updates**

    * **Description:** Ensure token prices and changes are updated in real-time.

    * **Functionality:** Automatically refresh data at regular intervals (approximately 1 minute).

* **Non-Functional Requirements**

    * **Performance:** Ensure quick loading times and smooth updates for the token list.

    * **Usability:** Provide an intuitive layout that is easy to navigate and understand.

    * **Security:** Ensure secure handling of data and user interactions with the swap feature.

    * **Error Handling:** If there is a failure in retrieving token data, use the latest data without breaking the app.

--- 

### Token Detail

* **Functional Requirements**

  * **Overview:** The Token Detail feature provides users with comprehensive information about a specific cryptocurrency, including price trends and statistics. It allows users to make informed decisions and initiate trades.

  * **Features:**

      * **Token Information Display**

          * **Description:** Show detailed information about the corresponding token.

          * **Fields:**

              * **Token Name and Symbol:** Displayed prominently at the top.

              * **Current Price:** Latest price in the chosen currency.

              * **Price Change:** Percentage change with visual indicators (e.g., color-coded arrows).

      * **Price Chart**

          * **Description:** Provide a visual representation of the token's price history.

          * **Functionality:** Interactive chart with time frame options (1D, 1W, 1M, 1Y).

      * **Statistics Section**

          * **Description:** Display key statistics about the token.

          * **Fields:**

              - Market Cap: Total market capitalization.

              - Total Supply: Total number of tokens.

              - Circulating Supply: Number of tokens currently in circulation.

              - Volume (24H/7D): Trading volume over specified periods.

              - Avg. Price: The weighted arithmetic mean of all related ADA pools.

              - Avg. Price Change (24H): The price from the weighted arithmetic mean of all related ADA pools.

              - Decimal: Refers to the number of digits used after the decimal point for a specific token; it dictates the smallest indivisible unit of that token.

      * **About Section**

          - **Description:** Provide a brief description and additional information about the token.

          - **Content:** Overview of the token's purpose and features; tags indicating categories (e.g., DEX, DeFi).

      * **Alerts and Warnings**

          - **Description:** Display alerts or warnings related to the token.

          - **Functionality:** Indicate if a token is unverified or flagged as a scam.

      * **External Links**

          - **Description:** Provide links to external resources for more information.

          - **Functionality:** Icons linking to social media, official website, etc.

      * **Trade Button**

          - **Description:** Allow users to initiate a trade for the selected token.

          - **Functionality:** Directs users to the trading interface.

* **Non-Functional Requirements**

    - Performance: Ensure quick loading times for data and charts.

    - Usability: Provide an intuitive layout that is easy to navigate and understand.

    - Security: Ensure secure handling of data and user interactions with external links.

    - Error Handling: If there is a failure in loading token details or chart data, display an error message stating "Unable to load token details. Please try again later."
---

### Search

* **Functional Requirements**

  * **Overview:** The Search feature allows users to quickly find and access information about tokens on the platform. It includes recent searches, top tokens, and a search bar for easy navigation.

  * **Features:**

      * **Search Icon**

          - **Description:** Provide an entry point for users to start searching.

          - **Functionality:** Opens the search bar.

      * **Search Bar**

          - **Description:** Provides an input field for users to find specific tokens.

          - **Functionality:**

              - Auto-suggest as users type.

              - Display relevant results dynamically.

      * **Recent Searches**

          - **Description:** Show a list of five recent searches for quick access.

          - **Functionality:** Allow users to clear individual or all recent searches.

      * **Top Tokens Display**

          - **Description:** Highlight top tokens based on volume or popularity.

          - **Functionality:** Update dynamically based on real-time data.

      * **Token List with Details**

          - **Description:** Display a list of tokens with brief details.

          - Fields:

              - Token Name and Symbol

              - Current Price

              - Percentage Change

          - Functionality: Display a default list of top five trending tokens (based on volume over 24 hours) when there is no input.

* **Non-Functional Requirements**

  * Performance: Ensure fast response times for search queries.

  * Usability: Provide an intuitive interface that is easy to navigate and understand.

  * Security: Ensure secure handling of user data related to searches.

  * Error Handling: If no tokens match the search query, display an empty state along with a message stating "No results found."