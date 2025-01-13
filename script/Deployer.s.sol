// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FluidkeySavingsModule} from "src/FluidkeySavingsModule.sol";

contract Create2Deployment is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new FluidkeySavingsModule{salt: bytes32("f100ed4ee")}(0xDF54D2323E6698fcAb01b621504150F3d2Cc4Fb4);
        vm.stopBroadcast();
    }
}
