// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFoundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; //相当于部署了一个合约在虚拟机上
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user"); //创建一个虚拟用户

    function setUp() external {
        //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFoundMe deployer = new DeployFoundMe();
        fundMe = deployer.run();
        vm.deal(USER, STARTING_BALANCE); //虚拟用户的地址是USER，给虚拟用户发钱
    }

    function testMinimumusdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailWithoutEnoughETH() public {
        //这个函数的意思是下面这行的代码如果执行成功就会报错，执行失败就会跳过
        vm.expectRevert();
        fundMe.fund(); //因为fund需要传入钱，没有传入就会报错所以测试不会报错
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //允许你在一系列测试中临时改变msg.sender的值以及在特定情况下tx.origin
        fundMe.fund{value: SEND_VALUE}();
        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, SEND_VALUE);
    }

    function testGetFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerWithdraw() public fundMoney {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    modifier fundMoney() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testSingleFunderWithdraw() public fundMoney {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundeMeBalance = address(fundMe).balance;
        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        /*得到调用这个函数花费的gas
        vm.txGasPrice(2);
        uint256 gasStart = gasleft(); //gasleft是当前剩余的gas，Solidity内置函数
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);
         */
        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundeMeBalance = address(fundMe).balance;
        assertEq(endingFundeMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundeMeBalance);
    }

    function testMulitipleFunderWithdraw() public {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 addressToAmountFundedIndex = 1;
        //act
        //模拟不同的用户给合约钱
        for (uint160 i = addressToAmountFundedIndex; i < numberOfFunders; i++) {
            //address(i)表示将一个整数 i 转换为地址类型 address,所以需要类型是UINT160
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundeMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        //assert
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundeMeBalance);
    }

    function testMulitipleFunderWithdrawCheaper() public {
        //arrange
        uint160 numberOfFunders = 10;
        uint160 addressToAmountFundedIndex = 1;
        //act
        //模拟不同的用户给合约钱
        for (uint160 i = addressToAmountFundedIndex; i < numberOfFunders; i++) {
            //address(i)表示将一个整数 i 转换为地址类型 address,所以需要类型是UINT160
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundeMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdrawCheaper();
        vm.stopPrank();
        //assert
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundeMeBalance);
    }
}
