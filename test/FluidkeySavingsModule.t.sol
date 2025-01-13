// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Test } from "forge-std/Test.sol";
import { FluidkeySavingsModule } from "../src/FluidkeySavingsModule.sol";
import { SafeModuleSetup } from "../src/SafeModuleSetup.sol";
import { MultiSend } from "../lib/safe-tools/lib/safe-contracts/contracts/libraries/MultiSend.sol";
import { SafeProxyFactory } from
    "../lib/safe-tools/lib/safe-contracts/contracts/proxies/SafeProxyFactory.sol";
import { Safe } from "../lib/safe-tools/lib/safe-contracts/contracts/Safe.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";
import { SENTINEL } from "sentinellist/SentinelList.sol";
import { console } from "forge-std/console.sol";

contract FluidkeySavingsModuleTest is Test {
    // Contracts
    FluidkeySavingsModule internal module;
    SafeModuleSetup internal safeModuleSetup;
    MultiSend internal multiSend;
    SafeProxyFactory internal safeProxyFactory;

    // ERC20 contracts on Base
    IERC20 public USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    IERC20 public WETH = IERC20(0x4200000000000000000000000000000000000006);
    address public ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IERC4626 public RE7_USDC_ERC4626 = IERC4626(0x12AFDeFb2237a5963e7BAb3e2D46ad0eee70406e);
    IERC4626 public GAUNTLET_WETH_ERC4626 = IERC4626(0x6b13c060F13Af1fdB319F52315BbbF3fb1D88844);
    IERC4626 public STEAKHOUSE_USDC_ERC4626 = IERC4626(0xbeeF010f9cb27031ad51e3333f9aF9C6B1228183);

    address internal owner;
    address[] internal ownerAddresses;
    address internal authorizedRelayer;
    address internal safe;
    bytes internal moduleInitData;
    bytes internal moduleSettingData;
    bytes internal moduleData;
    uint256 internal baseFork;

    function setUp() public {
        // Create a fork on Base
        string memory DEPLOYMENT_RPC = vm.envString("DEPLOYMENT_RPC");
        baseFork = vm.createSelectFork(DEPLOYMENT_RPC);
        vm.selectFork(baseFork);

        // Create test addresses
        owner = makeAddr("bob");
        authorizedRelayer = makeAddr("relayer");

        // Initialize contracts
        module = new FluidkeySavingsModule(authorizedRelayer, address(WETH));
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
            new FluidkeySavingsModule.ConfigWithToken[](2);

        // Populate the array
        configs[0] = FluidkeySavingsModule.ConfigWithToken({
            token: address(USDC),
            vault: address(RE7_USDC_ERC4626)
        });
        configs[1] = FluidkeySavingsModule.ConfigWithToken({
            token: address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),
            vault: address(GAUNTLET_WETH_ERC4626)
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

    function test_Deployment() public view {
        bool isInitialized = module.isInitialized(safe);
        assertEq(isInitialized, true, "1: Module is not initialized");
    }

    function test_AutoSaveWithRelayerErc20() public {
        deal(address(USDC), safe, 100_000_000);
        vm.startPrank(authorizedRelayer);
        module.autoSave(address(USDC), 100_000_000, safe);
        uint256 balance = USDC.balanceOf(safe);
        assertEq(balance, 0, "1: USDC balance is not correct");
        uint256 balanceOfVault = RE7_USDC_ERC4626.balanceOf(safe);
        assertGt(balanceOfVault, 0, "2: USDC balance of vault is 0");
    }

    function test_AutoSaveWithRelayerEth() public {
        deal(safe, 1 ether);
        vm.startPrank(authorizedRelayer);
        module.autoSave(ETH, 1 ether, safe);
        uint256 balance = address(safe).balance;
        assertEq(balance, 0, "1: ETH balance is not correct");
        uint256 balanceOfVault = GAUNTLET_WETH_ERC4626.balanceOf(safe);
        assertGt(balanceOfVault, 0, "2: ETH balance of vault is 0");
    }

    function test_AutoSaveWithoutRelayer() public {
        deal(address(USDC), safe, 100_000_000);
        address unauthorizedRelayer = makeAddr("unauthorizedRelayer");
        vm.startPrank(unauthorizedRelayer);
        vm.expectRevert(
            abi.encodeWithSelector(
                FluidkeySavingsModule.NotAuthorized.selector, unauthorizedRelayer
            )
        );
        module.autoSave(address(USDC), 100_000_000, safe);
    }

    function test_UpdateConfig() public {
        vm.startPrank(safe);
        module.setConfig(address(USDC), address(STEAKHOUSE_USDC_ERC4626));
        vm.startPrank(authorizedRelayer);
        deal(address(USDC), safe, 100_000_000);
        module.autoSave(address(USDC), 100_000_000, safe);
        uint256 balance = USDC.balanceOf(safe);
        assertEq(balance, 0, "1: USDC balance is not correct");
        uint256 balanceOfVault = STEAKHOUSE_USDC_ERC4626.balanceOf(safe);
        assertGt(balanceOfVault, 0, "2: USDC balance of vault is 0");
    }

    function test_DeleteConfig() public {
        address[] memory tokens = module.getTokens(safe);
        vm.startPrank(safe);
        module.deleteConfig(SENTINEL, tokens[0]);
        tokens = module.getTokens(safe);
        module.deleteConfig(SENTINEL, tokens[0]);
        tokens = module.getTokens(safe);
        assertEq(tokens.length, 0, "1: Tokens are not deleted");
        deal(safe, 1 ether);
        vm.startPrank(authorizedRelayer);
        vm.expectRevert(
            abi.encodeWithSelector(FluidkeySavingsModule.ConfigNotFound.selector, address(ETH))
        );
        module.autoSave(ETH, 1 ether, safe);
    }

    function test_OnUninstall() public {
        vm.startPrank(safe);
        module.onUninstall();
        address[] memory tokens = module.getTokens(safe);
        assertEq(tokens.length, 0, "1: Tokens are not deleted");
    }
}
