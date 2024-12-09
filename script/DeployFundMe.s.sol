// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFoundMe is Script {
    function run() external returns (FundMe) {
        //将一些不必要放在链上的操作放在stratBoardcast之前
        HelperConfig helperconfig = new HelperConfig();
        address ethusdpricefeed = helperconfig.activenetworkconfig();

        vm.startBroadcast();
        FundMe fundme = new FundMe(ethusdpricefeed);
        vm.stopBroadcast();
        return fundme;
    }
}
