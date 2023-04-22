//SPDX-License-Identifier: LGPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Mech.sol";
import "./ImmutableStorage.sol";

/**
 * @dev A Mech that is operated by the holder of an ERC721 non-fungible token
 */
contract ERC721Mech is Mech, ImmutableStorage, UUPSUpgradeable, Initializable {



    IEntryPoint private immutable _entryPoint;

   constructor(IEntryPoint anEntryPoint) {
        _entryPoint = anEntryPoint;
        _disableInitializers();
    }

    function initialize(bytes memory initParams) public virtual initializer {
        _initialize(initParams);
    }

    function _initialize(bytes memory initParams) public {
        require(readImmutable().length == 0, "Already initialized");
        writeImmutable(initParams);
    }

    function token() public view returns (IERC721) {
        address _token = abi.decode(readImmutable(), (address));
        return IERC721(_token);
    }

    function tokenId() public view returns (uint256) {
        (, uint256 _tokenId) = abi.decode(readImmutable(), (address, uint256));
        return _tokenId;
    }

    function isOperator(address signer) public view override returns (bool) {
        (address _token, uint256 _tokenId) = abi.decode(
            readImmutable(),
            (address, uint256)
        );
        return IERC721(_token).ownerOf(_tokenId) == signer;
    }
        function _authorizeUpgrade(address newImplementation) internal view override {
        (newImplementation);
        require(isOperator(newImplementation), "not authorized");
    }
}
