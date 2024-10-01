// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ObinVesting is Ownable2Step{

    struct Transaction{
        uint amount;
        uint256 timestamp;
        address token; //ETH address(0)
    }

    uint monthlyAllowance; 
    uint monthInSeconds;
    uint public lastWithdrawalTime;
    Transaction [] public transactions;
    mapping (uint monthIndex => Transaction ) withdrawRecords;

    event newAllowanceSet(uint indexed OldAllowance, uint indexed NewAllowance);

    error InputNewAmount(uint OldAllowance, uint NewAllowance);

    constructor(address _owner,uint _monthlyAllowance){
        monthlyAllowance = _monthlyAllowance;
    }


    function reset_monthlyAllowance(uint _newAllowance) public onlyOwner {
        if (monthlyAllowance == _newAllowance) revert InputNewAmount()
        
        
        

    }

    function withdraw() public returns(bool){}

    function resetDecimal( ) public {}

    function renounceOwnership() public override {
        revert();
    }

    //========================================GETTERS=================================//
    //================================================================================//

    function ETHBalance() external view returns(uint){
        return this.balance;
        
    }
    function tokenBalance(address _token) external view returns(uint){
        return IERC20(_token).balanceOf(address(this));
    }

    function getDecimals(address _token) public view returns(uint){
        return IERC20(_token).decimals(); 
    }

    receive() external payable {
        require(msg.value > 0, "Must send some ETH");  
        transactions.push(Transaction(msg.value, block.timestamp, address(0), true)); // Track the ETH transaction 
    }
    //@audit if multiToken, beware of decimals effect.
}
