// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

// forge script script/NFT.s.sol:MyScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import "./ERC4337/core/BaseAccount.sol";

contract SmartWallet is BaseAccount {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    address public owner;

    IEntryPoint private immutable _entryPoint;

    event SimpleAccountInitialized(
        IEntryPoint indexed entryPoint,
        address indexed owner
    );

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    receive() external payable {}

    constructor(IEntryPoint entryPoint_, address _owner) {
        _entryPoint = entryPoint_;
        owner = _owner;
    }

    function _onlyOwner() internal view {
        require(
            msg.sender == owner || msg.sender == address(this),
            "only owner"
        );
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual returns (uint256 validationData) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        if (owner != hash.recover(userOp.signature))
            return SIG_VALIDATION_FAILED;
        return 0;
    }

    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    function withdrawDepositTo(
        address payable withdrawAddress,
        uint256 amount
    ) public onlyOwner {
        entryPoint().withdrawTo(withdrawAddress, amount);
    }
}
