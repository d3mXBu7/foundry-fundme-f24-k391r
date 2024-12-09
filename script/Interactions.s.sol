// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//这个文件的作用的是对于整体的FundMe合约的测试
//主要测试时两个功能Fund和Withdraw

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostrecentdeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentdeployment)).fund{value: SEND_VALUE}(); //得到合约地址给合约捐款
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        //我们希望得到的是对最近部署的合约进行捐款，因此要获得最新的合约信息
        //利用foundry-devops 得到新部署的合约的最新地址
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(contractAddress);
    }
}

contract WithdrawFundMe is Script {
    function fundFundMe(address mostrecentdeployment) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentdeployment)).withdrawCheaper(); //得到合约地址给合约捐款
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address contractAddress = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(contractAddress);
    }
}
