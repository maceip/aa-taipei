//SPDX-License-Identifier: LGPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./base/Mech.sol";
import "./base/ImmutableStorage.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/**
 * @dev A Mech that is operated by the holder of an ERC721 non-fungible token
 */
contract ERC721Mech is Mech, ImmutableStorage, UUPSUpgradeable, Initializable {


    address public token;

    IEntryPoint private immutable _entryPoint;

        modifier onlyOwner() {
        _onlyOwner();
        _;
    }

        constructor(IEntryPoint anEntryPoint, uint256 anERC721id) {
        _entryPoint = anEntryPoint;
        _disableInitializers();
    }

    event MechInitialized(IEntryPoint indexed entryPoint, address indexed token);

        function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }


    function initialize(address anOwner, uint256 anERC721id) public virtual initializer {
        _initialize(anOwner,anERC721id);
    }

    function _initialize(address anOwner, anERC721id) internal virtual {
        owner = anOwner;
        token = anERC721id;
        emit SimpleAccountInitialized(_entryPoint, owner);
    }

    /// @param _token Address of the token contract
    /// @param _tokenId The token ID
    constructor(address _token, uint256 _tokenId) {
        bytes memory initParams = abi.encode(_token, _tokenId);
        setUp(initParams);
    }

    function setUp(bytes memory initParams) public override {
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
}
