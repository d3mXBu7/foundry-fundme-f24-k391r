// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // 如果我们是在本地测试,那么使用本地的测试网络
    // 不然我们就根据ChainId来判断返回运用哪个网络的地址
    NetworkConfig public activenetworkconfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activenetworkconfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activenetworkconfig = getMainEthConfig();
        } else {
            activenetworkconfig = getOrCreateAnvilEthConfig();
        }
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activenetworkconfig.priceFeed != address(0)) {
            return activenetworkconfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvileth = NetworkConfig({priceFeed: address(mockV3Aggregator)});
        return anvileth;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaeth = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaeth;
    }

    function getMainEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainliaeth = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainliaeth;
    }
    
}
