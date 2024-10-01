// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;  

// ERC20 Interface  
interface IERC20 {  
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);  
    function transfer(address recipient, uint256 amount) external returns (bool);  
    function balanceOf(address account) external view returns (uint256);  
}  

contract MultiAssetVesting {  
    address public owner;  
    uint256 public monthlyWithdrawalLimit;  
    uint256 public lastWithdrawalTime;  

    struct TokenInfo {  
        uint256 balance;  
        uint256 timestamp;  
    }  

    mapping(address => TokenInfo) public tokenBalances; // track balance of each token  
    address[] public tokenList; // store the list of accepted tokens  
    mapping(address => bool) public acceptedTokens; // to avoid duplicates  

    struct Transaction {  
        uint256 amount;  
        uint256 timestamp;  
        address tokenAddress; // address of the token  
        bool isETH; // Indicates whether the transaction is ETH or token  
    }  

    Transaction[] public transactions;  

    modifier onlyOwner() {  
        require(msg.sender == owner, "Only the owner can perform this action");  
        _;  
    }  

    constructor(uint256 _monthlyWithdrawalLimit) {  
        owner = msg.sender; // Set the deployer as the owner  
        monthlyWithdrawalLimit = _monthlyWithdrawalLimit; // Set the withdrawal limit  
        lastWithdrawalTime = block.timestamp; // Initialize last withdrawal time  
    }  

    // Allow the contract to receive ETH  
    receive() external payable {  
        require(msg.value > 0, "Must send some ETH");  
        transactions.push(Transaction(msg.value, block.timestamp, address(0), true)); // Track the ETH transaction  
    }  

    // Deposit ERC20 tokens  
    function depositTokens(address token, uint256 amount) external onlyOwner {  
        require(amount > 0, "Deposit must be greater than 0");  
        IERC20(token).transferFrom(msg.sender, address(this), amount); // Transfer tokens from the owner to the contract  
        
        if (!acceptedTokens[token]) {  
            acceptedTokens[token] = true; // Mark this token as accepted  
            tokenList.push(token); // Add it to the list of accepted tokens  
        }  

        tokenBalances[token].balance += amount; // Update the token balance  
        transactions.push(Transaction(amount, block.timestamp, token, false)); // Track the token transaction  
    }  

    // Withdraw ETH  
    function withdrawETH(uint256 amount) external onlyOwner {  
        require(amount <= monthlyWithdrawalLimit, "Amount exceeds monthly limit");  
        require(block.timestamp >= lastWithdrawalTime + 30 days, "Withdrawal not allowed yet");  
        require(address(this).balance >= amount, "Insufficient ETH balance");  

        lastWithdrawalTime = block.timestamp; // Update last withdrawal time  
        payable(owner).transfer(amount); // Send ETH to the owner  
        transactions.push(Transaction(amount, block.timestamp, address(0), true)); // Track withdrawal transaction  
    }  

    // Withdraw ERC20 tokens  
    function withdrawTokens(address token, uint256 amount) external onlyOwner {  
        require(amount <= monthlyWithdrawalLimit, "Amount exceeds monthly limit");  
        require(block.timestamp >= lastWithdrawalTime + 30 days, "Withdrawal not allowed yet");  
        require(tokenBalances[token].balance >= amount, "Insufficient token balance");  

        lastWithdrawalTime = block.timestamp; // Update last withdrawal time  
        tokenBalances[token].balance -= amount; // Update the balance  
        IERC20(token).transfer(owner, amount); // Transfer tokens to the owner  
        transactions.push(Transaction(amount, block.timestamp, token, false)); // Track withdrawal transaction  
    }  

    function getTransactionCount() external view returns (uint256) {  
        return transactions.length; // Get the number of transactions  
    }  

    function getTransaction(uint256 index) external view returns (uint256 amount, uint256 timestamp, address tokenAddress, bool isETH) {  
        require(index < transactions.length, "Transaction does not exist"); // Check for valid index  
        Transaction memory txn = transactions[index];  
        return (txn.amount, txn.timestamp, txn.tokenAddress, txn.isETH); // Return the transaction details  
    }  

    function getETHBalance() external view returns (uint256) {  
        return address(this).balance; // Get the contract's ETH balance  
    }  

    function getTokenBalance(address token) external view returns (uint256) {  
        return tokenBalances[token].balance; // Get the balance of the specific token  
    }  
    
    function getAcceptedTokens() external view returns (address[] memory) {  
        return tokenList; // Get the list of accepted tokens  
    }  
}