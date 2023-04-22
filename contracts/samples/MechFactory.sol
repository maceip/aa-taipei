// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "./ERC721Mech.sol";

/**
 * A sample factory contract for SimpleAccount
 * A UserOperations "initCode" holds the address of the factory, and a method call (to createAccount, in this sample factory).
 * The factory's createAccount returns the target account address even if it is already installed.
 * This way, the entryPoint.getSenderAddress() can be called either before or after the account is created.
 */
contract MechFactory {
    ERC721Mech public immutable mech721implementation;


    constructor(IEntryPoint _entryPoint) {
        mech721implementation = new ERC721Mech(_entryPoint,0);
    }

    /**
     * create an account, and return its address.
     * returns the address even if the account is already deployed.
     * Note that during UserOperation execution, this method is called only if the account is not deployed.
     * This method returns an existing account address so that entryPoint.getSenderAddress() would work even after account creation
     */
    function createMech(address token,uint256 id, uint salt) public returns (ERC721Mech ret) {
        address addr = getAddress(token, id,  salt);
        uint codeSize = addr.code.length;
        if (codeSize > 0) {
            revert("mech already exists at this address");
        }
        ret = ERC721Mech((new ERC1967Proxy{salt : bytes32(salt)}(
                address(mech721implementation),
                abi.encodeCall(ERC721Mech.initialize, (owner))
            )));
    }

    /**
     * calculate the counterfactual address of this account as it would be returned by createAccount()
     */
    function getAddress(address owner, uint256 id, uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt), keccak256(abi.encodePacked(
                type(ERC1967Proxy).creationCode,
                abi.encode(
                    address(accountImplementation),
                    abi.encodeCall(ERC721Mech.initialize, (token, id))
                )
            )));
    }
}
