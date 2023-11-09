// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "./SmartWallet.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

/// @notice Factory contract to deploy user smart wallets. Expected to be passed the bytecode of the user
///         smart wallet
contract SmartWalletFactory {
    IEntryPoint public immutable entryPoint;
    mapping(address => SmartWallet) public userWallet;
    mapping(address => bool) public userWalletExist;

    constructor(IEntryPoint _entryPoint) {
        entryPoint = _entryPoint;
    }

    function deployWallet(uint256 salt) external returns (SmartWallet) {
        address walletAddress = computeAddress(salt);

        // Determine if a wallet is already deployed at this address, if so return that
        uint256 codeSize = walletAddress.code.length;
        if (codeSize > 0) {
            return CustodialWallet(payable(walletAddress));
        } else {
            // Deploy the wallet
            SmartWallet wallet = new SmartWallet{salt: bytes32(salt)}(
                entryPoint,
                msg.sender
            );
            return wallet;
        }
    }

    /// @notice Deterministically compute the address of a smart wallet using Create2
    function computeAddress(uint256 salt) public view returns (address) {
        return
            Create2.computeAddress(
                bytes32(salt),
                keccak256(
                    abi.encodePacked(
                        type(SmartWallet).creationCode,
                        abi.encode(entryPoint, msg.sender)
                    )
                )
            );
    }

    function hasAnAccountAndReturn()
        external
        view
        returns (SmartWallet userAccount)
    {
        require(userWalletExist[msg.sender] == true, "No Account Found");
        userAccount = userWallet[msg.sender];
    }
}
