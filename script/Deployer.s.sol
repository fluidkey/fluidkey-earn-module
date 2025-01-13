// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { FluidkeyEarnModule } from "../src/FluidkeyEarnModule.sol";
import { CREATE3Factory } from "create3-factory/src/CREATE3Factory.sol";
import { console } from "forge-std/console.sol";

contract Create3Deployment is Script {
    CREATE3Factory factory = CREATE3Factory(0x9fBB3DF7C40Da2e5A0dE984fFE2CCB7C47cd0ABf);

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
