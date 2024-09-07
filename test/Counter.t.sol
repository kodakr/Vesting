// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ObinVesting} from "../src/ObinVesting.sol";

contract CounterTest is Test {
    ObinVesting public bank;
    uint monthlyAllowance;

    function setUp() public {
        //bank = new ObinVesting(monthlyAllowance);
        
    }

}