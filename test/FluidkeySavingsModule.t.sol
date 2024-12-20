// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import "safe-tools/SafeTestTools.sol";
import { FluidkeySavingsModule } from "../src/FluidkeySavingsModule.sol";
import { SafeModuleSetup } from "../src/SafeModuleSetup.sol";
import { MultiSend } from "../lib/safe-tools/lib/safe-contracts/contracts/libraries/MultiSend.sol";
import { SafeProxyFactory } from
    "../lib/safe-tools/lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import { Safe } from "../lib/safe-tools/lib/safe-contracts/contracts/Safe.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";
import { ud2x18 } from "@prb/math/UD2x18.sol";

contract FluidkeySavingsModuleTest is Test {
    // Contracts
    FluidkeySavingsModule internal module;
    SafeModuleSetup internal safeModuleSetup;
    MultiSend internal multiSend;
    SafeProxyFactory internal safeProxyFactory;

    // ERC20 contracts on Base
    IERC20 public USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    IERC4626 public RE7_USDC_ERC4626 = IERC4626(0x12AFDeFb2237a5963e7BAb3e2D46ad0eee70406e);

    address owner;
    address[] ownerAddresses;
    address loan;
    address repay;
    address authorizedRelayer;
    address safe;
    bytes moduleInitData;
    bytes moduleSettingData;
    bytes moduleData;
    address payable safeInstance;
    uint256 baseFork;

    function setUp() public {
        // Create a fork on Base
        string memory DEPLOYMENT_RPC = vm.envString("DEPLOYMENT_RPC");
        baseFork = vm.createSelectFork(DEPLOYMENT_RPC);
        vm.selectFork(baseFork);

        // Create test addresses
        owner = makeAddr("bob");
        authorizedRelayer = makeAddr("relayer");

        // Initialize contracts
        module = new FluidkeySavingsModule(authorizedRelayer);
        safeModuleSetup = SafeModuleSetup(0x2dd68b007B46fBe91B9A7c3EDa5A7a1063cB5b47);
        multiSend = MultiSend(0x38869bf66a61cF6bDB996A6aE40D5853Fd43B526);
        safeProxyFactory = SafeProxyFactory(0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67);

        // Prepare the FluidkeySavingsModule init and setting data as part of a multisend tx
        address[] memory modules = new address[](1);
        modules[0] = address(module);
        moduleInitData = abi.encodeWithSelector(safeModuleSetup.enableModules.selector, modules);
        uint256 moduleInitDataLength = moduleInitData.length;
        // Create a dynamic array of ConfigWithToken
        FluidkeySavingsModule.ConfigWithToken[] memory configs =
            new FluidkeySavingsModule.ConfigWithToken[](1);

        // Populate the array
        configs[0] = FluidkeySavingsModule.ConfigWithToken({
            token: address(USDC),
            vault: address(RE7_USDC_ERC4626)
        });

        moduleSettingData = abi.encodeWithSelector(module.onInstall.selector, abi.encode(configs));

        uint256 moduleSettingDataLength = moduleSettingData.length;
        bytes memory multisendData = abi.encodePacked(
            uint8(1),
            address(safeModuleSetup),
            uint256(0),
            moduleInitDataLength,
            moduleInitData,
            uint8(0),
            address(module),
            uint256(0),
            moduleSettingDataLength,
            moduleSettingData
        );
        multisendData = abi.encodeWithSelector(multiSend.multiSend.selector, multisendData);
        ownerAddresses = new address[](1);
        ownerAddresses[0] = owner;
        bytes memory initData = abi.encodeWithSelector(
            Safe.setup.selector,
            ownerAddresses,
            1,
            address(multiSend),
            multisendData,
            address(0),
            address(0),
            0,
            payable(address(0))
        );

        // Deploy the Safe
        safe = payable(
            safeProxyFactory.createProxyWithNonce(
                address(0x29fcB43b46531BcA003ddC8FCB67FFE91900C762), initData, 100
            )
        );
    }

    function test_Deployment() public {
        // check that the module is initialized
        bool isInitialized = module.isInitialized(safe);
        assertEq(isInitialized, true, "1: Module is not initialized");
    }

    function test_AutoSave() public {
        deal(address(USDC), safe, 100_000_000);
        vm.startPrank(authorizedRelayer);
        module.autoSave(address(USDC), 100, safe);
    }
}
