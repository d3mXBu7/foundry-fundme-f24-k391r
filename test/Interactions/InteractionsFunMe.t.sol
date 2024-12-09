// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFoundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";

contract InteractionsFunMe is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address BEN = makeAddr("ben");

    function setUp() public {
        DeployFoundMe deployer = new DeployFoundMe();
        fundMe = deployer.run();
        vm.deal(BEN, STARTING_BALANCE);
    }

    function testFundFundMeAndeWithdraw() public {
        //测试fund函数
        FundFundMe funFundMe = new FundFundMe();
        funFundMe.fundFundMe(address(fundMe));

        //测试withdraw函数
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.fundFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }

    ///这一部分我的理解就是对于功能的完整性的测试，测试整一个函数
    ///函数的调用测试直接在Script脚本完成。
    ///没有用到脚本的run函数应该是DevOpsTools需要联网吧，直接在本地测试的话就给一个合约地址就是最新的合约地址了
}
