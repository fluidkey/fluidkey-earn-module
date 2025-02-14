## Fluidkey Savings Module

The Fluidkey Savings Module is a Safe module that allows Fluidkey to automatically deposit funds into an ERC-4626 vault on behalf of the Safe. It is based on the [AutoSavings module](https://github.com/rhinestonewtf/core-modules/blob/main/src/AutoSavings/AutoSavings.sol) authored by Rhinestone.

## Deployment

* Salt: `f10ed4ee` (production) and `de4e` (development)
* Create3 factory: `0x9fbb3df7c40da2e5a0de984ffe2ccb7c47cd0abf`
* Create3 deployer: `0x9E3eba321427941868cB4123De97DAB145C9e7CD`

To generate the encoded calldata for Create3 deploy, run the following command:
```bash
forge script script/Deployer.s.sol <authorized_relayer> <wrapped_native_address> <salt> --sig 'run(address,address,bytes)'
```

[!CAUTION]
Make sure to use the correct wrapped native asset address for the chain you are deploying to as this cannot be changed once the contract is deployed.

To verify the contract on Etherscan, run the following command:
```bash
forge verify-contract \
    --chain-id 8453 \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" <authorized_relayer> <wrapped_native_address>) \
    --etherscan-api-key <etherscan_api_key> \
    --compiler-version v0.8.23 \
    <contract_address> \
    src/FluidkeyEarnModule.sol:FluidkeyEarnModule
```
