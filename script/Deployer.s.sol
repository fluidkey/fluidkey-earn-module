// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/create3-factory/src/ICREATE3Factory.sol";
import { FluidkeyEarnModule } from "../src/FluidkeyEarnModule.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

contract Create3Deployment is Script {
    ICREATE3Factory factory = ICREATE3Factory(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);

    function run(address authorizedRelayer, address weth, bytes calldata salt) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address module = factory.deploy(
            bytes32(salt),
            abi.encodePacked(
                type(FluidkeyEarnModule).creationCode, abi.encode(authorizedRelayer, weth)
            )
        );
        console.log("Module deployed at:", module);
        vm.stopBroadcast();
    }
}
