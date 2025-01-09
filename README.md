## Fluidkey Savings Module

The Fluidkey Savings Module is a Safe module that allows Fluidkey to automatically deposit funds into an ERC-4626 vault on behalf of the Safe. It is based on the [AutoSavings module](https://github.com/rhinestonewtf/core-modules/blob/main/src/AutoSavings/AutoSavings.sol) authored by Rhinestone.

## Core commands

To build run `forge build` or `npx run build`

To deploy
```bash
forge create --rpc-url <your_rpc_url> \
    --constructor-args "0xauthAddress" \
    --private-key <your_private_key> \
    --etherscan-api-key <your_etherscan_api_key> \
    --verify \
    src/FluidkeySavingsModule.sol:FluidkeySavingsModule
```
