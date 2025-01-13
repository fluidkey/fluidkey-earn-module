## Fluidkey Savings Module

The Fluidkey Savings Module is a Safe module that allows Fluidkey to automatically deposit funds into an ERC-4626 vault on behalf of the Safe. It is based on the [AutoSavings module](https://github.com/rhinestonewtf/core-modules/blob/main/src/AutoSavings/AutoSavings.sol) authored by Rhinestone.

## Core commands

To build run `forge build` or `npx run build`

To deploy:
* Create `.env` file with `PRIVATE_KEY=0xPrivateKey` and `BASESCAN_KEY=YourEtherscanApiKey`
* Run the deployment with the command `forge script script/Deployer.s.sol:Create2Deployment --rpc-url <your-rpc-url> --broadcast --verify -vvvv`

If you want to verify on other chains rather than Base:
* edit `foundry.toml` adding other chains and accordingly .env variables
