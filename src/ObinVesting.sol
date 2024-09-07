// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ObinVesting is Ownable2Step{

    uint monthlyAllowance; 
    uint monthInSeconds;
    uint private decimals;
    

    struct Receipt{
        uint amount;
        address token; //ETH address(0)

    }

    mapping (uint monthIndex => Receipt ) withdrawRecords;

    constructor(address _owner,uint _monthlyAllowance){
        monthlyAllowance = _monthlyAllowance;
    }


    function reset_monthlyAllowance() public onlyOwner {

    }

    function withdraw() public returns(bool){}

    function resetDecimal( ) public {}

    function renounceOwnership() public override {
        revert();
    }

    //========================================GETTERS=================================//
    //================================================================================//

    function ETHBalance() external view returns(uint){
        
    }
    function tokenBalance(address _token) external view returns(uint){
        return IERC20(_token).balanceOf(address(this));
    }

    receive() external payable {}
    
}
