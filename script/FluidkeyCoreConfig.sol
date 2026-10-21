// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { FluidkeyEarnModule } from "../src/FluidkeyEarnModule.sol";

/**
 * @title FluidkeyCoreConfig
 * @dev Contains the configuration for FluidkeyEarnModule across different chains
 */
library FluidkeyCoreConfig {
    // Chain IDs
    uint256 constant CHAIN_ID_MAINNET = 1;
    uint256 constant CHAIN_ID_BASE = 8453;
    uint256 constant CHAIN_ID_POLYGON = 137;
    uint256 constant CHAIN_ID_ARBITRUM = 42161;
    uint256 constant CHAIN_ID_GNOSIS = 100;
    uint256 constant CHAIN_ID_OPTIMISM = 10;

    // Native token address constant 
    address constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /**
     * @dev Returns the complete configuration array for all supported vaults across chains
     * @return configs Array of ConfigInput structs for all supported vaults
     */
    function getAllConfigs() internal pure returns (FluidkeyEarnModule.ConfigInput[] memory) {
        // Initialize array with the total number of configs from the CSV
        // TODO - remember to update the array length when adding new configs
        FluidkeyEarnModule.ConfigInput[] memory configs = new FluidkeyEarnModule.ConfigInput[](41);
        
        uint256 index = 0;

        // Base Chain Configs
        // Gauntlet USDC Prime on Base
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_BASE,
            token: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, // USDC
            vault: 0x050cE30b927Da55177A4914EC73480238BAD56f0 // Gauntlet USDC Prime (Morpho v2.0)
        });

        // Gauntlet EURC Balanced on Base
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_BASE,
            token: 0x60a3E35Cc302bFA44Cb288Bc5a4F316Fdb1adb42, // EURC
            vault: 0x94Af495DE1F56Aa5576dEB17986bDCeE5Dd9778D // Gauntlet EURC Balanced (Morpho v2.0)
        });

        // Gauntlet WETH Balanced on Base
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_BASE,
            token: 0x4200000000000000000000000000000000000006, // WETH
            vault: 0xFeFeC33668E22677c4762d0853d56245a800ff08 // Gauntlet WETH Balanced (Morpho v2.0)
        });

        // Gauntlet WETH Balanced for ETH (native) on Base
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_BASE,
            token: NATIVE_TOKEN, // ETH
            vault: 0xFeFeC33668E22677c4762d0853d56245a800ff08 // Gauntlet WETH Balanced (Morpho v2.0)
        });

        // Gauntlet cbBTC Core on Base
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_BASE,
            token: 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf, // cbBTC
            vault: 0x6770216aC60F634483Ec073cBABC4011c94307Cb // Gauntlet cbBTC Core
        });

        // Polygon Chain Configs
        // Aave USDC on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359, // USDC
            vault: 0x2dCa80061632f3F87c9cA28364d1d0c30cD79a19 // Aave USDC
        });

        // Aave USDT on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: 0xc2132D05D31c914a87C6611C10748AEb04B58e8F, // USDT
            vault: 0x87A1fdc4C726c459f597282be639a045062c0E46 // Aave USDT
        });

        // Aave wBTC on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, // wBTC
            vault: 0xbC0f50CCB8514Aa7dFEB297521c4BdEBc9C7d22d // Aave wBTC
        });

        // Aave wETH on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619, // wETH
            vault: 0xb3D5Af0A52a35692D3FcbE37669b3B8C31dddE7D // Aave wETH
        });

        // Aave wPOL on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, // wPOL
            vault: 0x98254592408E389D1dd2dBa318656C2C5c305b4E // Aave wPOL
        });

        // Aave wPOL for POL (native) on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: NATIVE_TOKEN, // POL
            vault: 0x98254592408E389D1dd2dBa318656C2C5c305b4E // Aave wPOL
        });

        // Aave DAI on Polygon
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_POLYGON,
            token: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063, // DAI
            vault: 0x83c59636e602787A6EEbBdA2915217B416193FcB // Aave DAI
        });

        // Arbitrum Chain Configs
        // Aave wETH on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1, // wETH
            vault: 0x352F3475716261dCC991Bd5F2aF973eB3D0F5878 // Aave wETH
        });

        // Aave wETH for ETH (native) on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: NATIVE_TOKEN, // ETH
            vault: 0x352F3475716261dCC991Bd5F2aF973eB3D0F5878 // Aave wETH
        });

        // Aave USDT on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9, // USDT
            vault: 0xb165a74407fE1e519d6bCbDeC1Ed3202B35a4140 // Aave USDT
        });

        // Aave USDC on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831, // USDC
            vault: 0x7CFaDFD5645B50bE87d546f42699d863648251ad // Aave USDC
        });

        // Aave DAI on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, // DAI
            vault: 0xc91c5297d7E161aCC74b482aAfCc75B85cc0bfeD // Aave DAI
        });

        // Aave wBTC on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f, // wBTC
            vault: 0x32B95Fbe04e5a51cF99FeeF4e57Cf7e3FC9c5A93 // Aave wBTC
        });

        // Aave GHO on Arbitrum
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_ARBITRUM,
            token: 0x7dfF72693f6A4149b17e7C6314655f6A9F7c8B33, // GHO
            vault: 0xD9FBA68D89178e3538e708939332c79efC540179 // Aave GHO
        });

        // Gnosis Chain Configs
        // Aave GNO on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: 0x9C58BAcC331c9aa871AFD802DB6379a98e80CEdb, // GNO
            vault: 0x2D737e2B0e175f05D0904C208d6C4e40da570f65 // Aave GNO
        });

        // Aave wxDAI on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: 0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d, // wxDAI
            vault: 0x7f0EAE87Df30C468E0680c83549D0b3DE7664D4B // Aave xDAI
        });

        // Aave xDAI for xDAI (native) on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: NATIVE_TOKEN, // xDAI
            vault: 0x7f0EAE87Df30C468E0680c83549D0b3DE7664D4B // Aave xDAI
        });

        // Aave EURe on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: 0xcB444e90D8198415266c6a2724b7900fb12FC56E, // EURe
            vault: 0x8418D17640a74F1614AC3E1826F29e78714488a1 // Aave EURe
        });

        // Aave wETH on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: 0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1, // wETH
            vault: 0xD843FB478c5aA9759FeA3f3c98D467e2F136190a // Aave wETH
        });

        // Aave USDC.e on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: 0x2a22f9c3b484c3629090FeED35F17Ff8F88f76F0, // USDC.e
            vault: 0xf0E7eC247b918311afa054E0AEdb99d74c31b809 // Aave USDC.e
        });

        // Aave USDC on Gnosis
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_GNOSIS,
            token: 0xDDAfbb505ad214D7b80b1f830fcCc89B60fb7A83, // USDC
            vault: 0x270bA1f35D8b87510D24F693fcCc0da02e6E4EeB // Aave USDC
        });

        // Optimism Chain Configs
        // Aave wETH on Optimism
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_OPTIMISM,
            token: 0x4200000000000000000000000000000000000006, // wETH
            vault: 0x98d69620C31869fD4822ceb6ADAB31180475FD37 // Aave wETH
        });

        // Aave wETH for ETH (native) on Optimism
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_OPTIMISM,
            token: NATIVE_TOKEN, // ETH
            vault: 0x98d69620C31869fD4822ceb6ADAB31180475FD37 // Aave wETH
        });

        // Aave USDC on Optimism
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_OPTIMISM,
            token: 0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85, // USDC
            vault: 0x4DD03dfD36548C840B563745e3FBeC320F37BA7e // Aave USDC
        });

        // Aave USDT on Optimism
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_OPTIMISM,
            token: 0x94b008aA00579c1307B0EF2c499aD98a8ce58e58, // USDT
            vault: 0x035c93db04E5aAea54E6cd0261C492a3e0638b37 // Aave USDT
        });

        // Aave DAI on Optimism
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_OPTIMISM,
            token: 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1, // DAI
            vault: 0x6dDc64289bE8a71A707fB057d5d07Cc756055d6e // Aave DAI
        });
        
        // AAVE wBTC on Optimism
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_OPTIMISM,
            token: 0x68f180fcCe6836688e9084f035309E29Bf0A2095, // wBTC
            vault: 0x6d998FeEFC7B3664eaD09CAf02b5a0fc2E365F18 // Aave wBTC
        });

        // Mainnet Chain Configs
        // Gauntlet USDC Prime on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC
            vault: 0x8c106EEDAd96553e64287A5A6839c3Cc78afA3D0 // Gauntlet USDC Prime (Morpho v2.0)
        });

        // Gauntlet USDT Prime on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0xdAC17F958D2ee523a2206206994597C13D831ec7, // USDT
            vault: 0xf3557AD5E984211ac8A0874A670344f2C3376471 // Gauntlet USDT Prime (Morpho v2.0)
        });

        // Gauntlet WETH Prime on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2, // wETH
            vault: 0x43fCd85E8D9D003D515f886891B7C742AC9f92da // Gauntlet WETH Prime (Morpho v2.0)
        });

        // Gauntlet WETH Prime for ETH (native) on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: NATIVE_TOKEN, // ETH
            vault: 0x43fCd85E8D9D003D515f886891B7C742AC9f92da // Gauntlet WETH Prime (Morpho v2.0)
        });

        // Aave DAI on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0x6B175474E89094C44Da98b954EedeAC495271d0F, // DAI
            vault: 0xaf270C38fF895EA3f95Ed488CEACe2386F038249 // Aave DAI
        });

        // Gauntlet wBTC Core on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // wBTC
            vault: 0x443df5eEE3196e9b2Dd77CaBd3eA76C3dee8f9b2 // Gauntlet wBTC Core
        });

        // Gauntlet cbBTC Core on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf, // cbBTC
            vault: 0xF587f2e8AfF7D76618d3B6B4626621860FbD54e3 // Gauntlet cbBTC Core
        });

        // Gauntlet EURC Core on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0x1aBaEA1f7C830bD89Acc67eC4af516284b1bC33c, // EURC
            vault: 0x842A84Df61DbE701c5dAE345F3f8E64aF727E48C // Gauntlet EURC Core (Morpho v2.0)
        });

        // fxSAVE on Mainnet
        configs[index++] = FluidkeyEarnModule.ConfigInput({
            chainId: CHAIN_ID_MAINNET,
            token: 0x085780639CC2cACd35E474e71f4d000e2405d8f6, // fxUSD
            vault: 0x7743e50F534a7f9F1791DdE7dCD89F7783Eefc39 // fxSAVE
        });

        return configs;
    }
}