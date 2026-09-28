// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FluidkeyEarnModule} from "../src/FluidkeyEarnModule.sol";
import {FluidkeyCoreConfig} from "./FluidkeyCoreConfig.sol";
import {FluidkeyOptimizedConfig} from "./FluidkeyOptimizedConfig.sol";
import {FluidkeyKpkConfig} from "./FluidkeyKpkConfig.sol";
import {FluidkeyInfinifiConfig} from "./FluidkeyInfinifiConfig.sol";

contract ConfigSetterScript is Script {
    function run() public {
        // Get the full array of coreConfigs
        FluidkeyEarnModule.ConfigInput[] memory coreConfigs = FluidkeyCoreConfig.getAllConfigs();

        // Calculate configHash
        bytes32 rawHash = keccak256(abi.encode(coreConfigs));

        // Encode the calldata for setConfig
        bytes memory callData = abi.encodeWithSelector(
            FluidkeyEarnModule.setConfig.selector,
            coreConfigs
        );

        // Print info
        console.log("Number of configurations for Core:", coreConfigs.length);
        console.log("configHash for Core (hex):");
        console.logBytes32(rawHash);

        console.log("\nCalldata for setConfig for Core:");
        console.logBytes(callData);

        // Get the full array of configs for Optimized config
        FluidkeyEarnModule.ConfigInput[] memory optimizedConfigs = FluidkeyOptimizedConfig.getAllConfigs();
        // Calculate configHash
        bytes32 rawHashOptimizedConfig = keccak256(abi.encode(optimizedConfigs));

        // Encode the calldata for setConfig
        bytes memory callDataOptimizedConfig = abi.encodeWithSelector(
            FluidkeyEarnModule.setConfig.selector,
            optimizedConfigs
        );

        // Print info
        console.log("Number of configurations for Optimized:", optimizedConfigs.length);
        console.log("configHash for Optimized (hex):");
        console.logBytes32(rawHashOptimizedConfig);

        console.log("\nCalldata for setConfig for Optimized:");
        console.logBytes(callDataOptimizedConfig);

        // Get the full array of configs for KPK config
        FluidkeyEarnModule.ConfigInput[] memory kpkConfigs = FluidkeyKpkConfig.getAllConfigs();
        // Calculate configHash
        bytes32 rawHashKpkConfig = keccak256(abi.encode(kpkConfigs));

        // Encode the calldata for setConfig
        bytes memory callDataKpkConfig = abi.encodeWithSelector(
            FluidkeyEarnModule.setConfig.selector,
            kpkConfigs
        );

        // Print info
        console.log("Number of configurations for KPK:", kpkConfigs.length);
        console.log("configHash for KPK (hex):");
        console.logBytes32(rawHashKpkConfig);

        console.log("\nCalldata for setConfig for KPK:");
        console.logBytes(callDataKpkConfig);

        // Get the full array of configs for InfiniFi config
        FluidkeyEarnModule.ConfigInput[] memory infinifiConfigs = FluidkeyInfinifiConfig.getAllConfigs();
        // Calculate configHash
        bytes32 rawHashInfinifiConfig = keccak256(abi.encode(infinifiConfigs));

        // Encode the calldata for setConfig
        bytes memory callDataInfinifiConfig = abi.encodeWithSelector(
            FluidkeyEarnModule.setConfig.selector,
            infinifiConfigs
        );

        // Print info
        console.log("Number of configurations for InfiniFi:", infinifiConfigs.length);
        console.log("configHash for InfiniFi (hex):");
        console.logBytes32(rawHashInfinifiConfig);

        console.log("\nCalldata for setConfig for InfiniFi:");
        console.logBytes(callDataInfinifiConfig);
    }
}
