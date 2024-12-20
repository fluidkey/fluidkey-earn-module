// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.23;

/**
 * @title FluidkeySavingsModule
 * @dev This contract is based on a contract originally authored by Rhinestone.
 * The original contract can be found at
 * https://github.com/rhinestonewtf/core-modules/blob/main/src/AutoSavings/AutoSavings.sol.
 */
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { IERC4626 } from "forge-std/interfaces/IERC4626.sol";
import { SentinelListLib, SENTINEL } from "sentinellist/SentinelList.sol";

interface Safe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation
    )
        external
        returns (bool success);
    function getOwners() external view returns (address[] memory);
}

interface IWETH {
    function deposit() external payable;
}

contract FluidkeySavingsModule {
    using SentinelListLib for SentinelListLib.SentinelList;

    /*//////////////////////////////////////////////////////////////////////////
                            CONSTANTS & STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    error TooManyTokens();
    // error InvalidSqrtPriceLimitX96();
    error ModuleNotInitialized(address account);
    error TokenNotUnderlying(address token);
    error NotAuthorized(address relayer);

    uint256 internal constant MAX_TOKENS = 100;
    address public immutable WETH = 0x4200000000000000000000000000000000000006; // weth on Base
    address public authorizedRelayer;

    constructor(address _authorizedRelayer) {
        authorizedRelayer = _authorizedRelayer;
    }

    struct ConfigWithToken {
        address token; // address of the token
        address vault; // address of the vault
    }

    // account => token => Config
    mapping(address account => mapping(address token => address vault)) public config;

    // account => tokens
    mapping(address account => SentinelListLib.SentinelList) tokens;

    event ModuleInitialized(address indexed account);
    event ModuleUninitialized(address indexed account);
    event ConfigSet(address indexed account, address indexed token);
    event AutoSaveExecuted(address indexed smartAccount, address indexed token, uint256 amountIn);

    /*//////////////////////////////////////////////////////////////////////////
                                     CONFIG
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * Updates the authorized relayer
     * @dev the function will revert if the caller is not the authorized relayer
     *
     * @param newRelayer address of the new relayer
     */
    function updateAuthorizedRelayer(address newRelayer) external {
        if (msg.sender != authorizedRelayer) revert NotAuthorized(msg.sender);
        authorizedRelayer = newRelayer;
    }

    /**
     * Initializes the module with the tokens and their configurations
     * @dev data is encoded as follows: abi.encode([tokens], [configs])
     * @dev if there are more tokens than configs, the function will revert
     * @dev if there are more configs than tokens, the function will ignore the extra configs
     *
     * @param data encoded data containing the tokens and their configurations
     */
    function onInstall(bytes calldata data) external {
        // cache the account address
        address account = msg.sender;

        // decode the data to get the tokens and their configurations
        (ConfigWithToken[] memory _configs) = abi.decode(data, (ConfigWithToken[]));
        // setSwapRouter(swapRouter);

        // initialize the sentinel list
        tokens[account].init();

        // get the length of the tokens
        uint256 length = _configs.length;

        // check that the length of tokens is less than max
        if (length > MAX_TOKENS) revert TooManyTokens();

        // loop through the tokens, add them to the list and set their configurations
        for (uint256 i; i < length; i++) {
            address _token = _configs[i].token;
            address _vault = _configs[i].vault;
            config[account][_token] = _vault;
            tokens[account].push(_token);
        }

        emit ModuleInitialized(account);
    }

    /**
     * Handles the uninstallation of the module and clears the tokens and configurations
     * @dev the data parameter is not used
     */
    function onUninstall(bytes calldata) external {
        // cache the account address
        address account = msg.sender;

        // _deinitSwapRouter();

        // clear the configurations
        (address[] memory tokensArray,) = tokens[account].getEntriesPaginated(SENTINEL, MAX_TOKENS);
        uint256 tokenLength = tokensArray.length;
        for (uint256 i; i < tokenLength; i++) {
            delete config[account][tokensArray[i]];
        }

        // clear the tokens
        tokens[account].popAll();

        emit ModuleUninitialized(account);
    }

    /**
     * Checks if the module is initialized
     *
     * @param smartAccount address of the smart account
     * @return true if the module is initialized, false otherwise
     */
    function isInitialized(address smartAccount) public view returns (bool) {
        // check if the linked list is initialized for the smart account
        return tokens[smartAccount].alreadyInitialized();
    }

    /**
     * Sets the configuration for a token
     * @dev the function will revert if the module is not initialized
     * @dev this function can be used to set a new configuration or update an existing one
     *
     * @param token address of the token
     * @param vault address of the vault
     */
    function setConfig(address token, address vault) public {
        // cache the account address
        address account = msg.sender;
        // check if the module is not initialized and revert if it is not
        if (!isInitialized(account)) revert ModuleNotInitialized(account);

        // set the configuration for the token
        config[account][token] = vault;

        // add the token to the list if it is not already there
        if (!tokens[account].contains(token)) {
            tokens[account].push(token);
        }

        emit ConfigSet(account, token);
    }

    /**
     * Deletes the configuration for a token
     * @dev the function will revert if the module is not initialized
     *
     * @param prevToken address of the token stored before the token to be deleted
     * @param token address of the token to be deleted
     */
    function deleteConfig(address prevToken, address token) public {
        // cache the account address
        address account = msg.sender;

        // delete the configuration for the token
        delete config[account][token];

        // remove the token from the list
        tokens[account].pop(prevToken, token);

        emit ConfigSet(account, token);
    }

    /**
     * Gets a list of all tokens
     * @dev the function will revert if the module is not initialized
     *
     * @param account address of the account
     */
    function getTokens(address account) external view returns (address[] memory tokensArray) {
        // return the tokens from the list
        (tokensArray,) = tokens[account].getEntriesPaginated(SENTINEL, MAX_TOKENS);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODULE LOGIC
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * Executes the auto save logic
     *
     * @param token address of the token received
     * @param amountReceived amount received by the user
     */
    function autoSave(
        address token,
        uint256 amountReceived,
        address safe
    )
        // uint160 sqrtPriceLimitX96,
        // uint256 amountOutMinimum,
        // uint24 fee
        external
    {
        // check that the authorized relayer is the caller
        if (msg.sender != authorizedRelayer) revert NotAuthorized(msg.sender);

        // initialize the safe instance
        Safe safeInstance = Safe(safe);

        // get the configuration for the token
        address vaultAddress = config[safe][token];

        // get the vault
        IERC4626 vault = IERC4626(vaultAddress);

        // check if the config exists and revert if not
        if (address(vault) == address(0)) {
            revert ModuleNotInitialized(safe);
        }

        IERC20 tokenToSave;

        // if token is ETH, wrap it
        if (token == address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)) {
            safeInstance.execTransactionFromModule(
                address(WETH), 0, abi.encodeWithSelector(IWETH.deposit.selector, amountReceived), 0
            );
            tokenToSave = IERC20(WETH);
        } else {
            tokenToSave = IERC20(token);
        }

        // approve the vault to spend the token
        safeInstance.execTransactionFromModule(
            address(tokenToSave),
            0,
            abi.encodeWithSelector(IERC20.approve.selector, address(vault), amountReceived),
            0
        );

        // deposit to vault
        safeInstance.execTransactionFromModule(
            address(vault),
            0,
            abi.encodeWithSelector(IERC4626.deposit.selector, amountReceived, safe),
            0
        );

        // emit event
        emit AutoSaveExecuted(safe, token, amountReceived);
    }
}
