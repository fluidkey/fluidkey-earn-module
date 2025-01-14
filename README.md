## Fluidkey Savings Module

The Fluidkey Savings Module is a Safe module that allows Fluidkey to automatically deposit funds into an ERC-4626 vault on behalf of the Safe. It is based on the [AutoSavings module](https://github.com/rhinestonewtf/core-modules/blob/main/src/AutoSavings/AutoSavings.sol) authored by Rhinestone.

## Core commands

To build run `forge build` or `npx run build`

To deploy:
* Create `.env` file with `PRIVATE_KEY=0xPrivateKey` and `BASESCAN_KEY=YourEtherscanApiKey`
* Run the deployment with the command
  `forge script --chain <your-chain> script/Deployer.s.sol:Create3Deployment \
 <authorized_relayer> <weth_address> <salt_ex_0x01> --sig 'run(address,address,bytes)' --rpc-url \
 $DEPLOYMENT_RPC --broadcast --verify -vvvv`
* If it doesn't verify in that command, run the following script
  ```bash
  # to obtains the <encoded_contructor_args>
  cast abi-encode "constructor(address,address)" <authorized_relayer> <weth_address>
  # to verify the contract
  forge verify-contract --chain base --constructor-args <encoded_contructor_args> <contract_address> FluidkeyEarnModule
  ```

If you want to verify on other chains rather than Base:
* edit `foundry.toml` adding other chains and accordingly .env variables
