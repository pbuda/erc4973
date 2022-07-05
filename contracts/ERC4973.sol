//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC4973.sol";
import "./IERC721Metadata.sol";

import "@openzeppelin/contracts/interfaces/IERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ERC4973 is Context, IERC4973, IERC721Metadata, IERC165 {
    using Strings for uint256;

    string private _name;
    string private _symbol;

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _owners;

    error OwnerAddressZero();
    error InvalidTokenId(uint256 tokenId);
    error TokenAlreadyMinted(uint256 tokenId);
    error TokenNotOwned(address caller, uint256 tokenId);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view returns (string memory) {
        return "";
    }

    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) {
            revert OwnerAddressZero();
        }

        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert InvalidTokenId(tokenId);
        }

        return _owners[tokenId];
    }

    function _attest(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert OwnerAddressZero();
        }
        if (_owners[tokenId] != address(0)) {
            revert TokenAlreadyMinted(tokenId);
        }

        _owners[tokenId] = to;
        _balances[to] += 1;

        emit Attest(to, tokenId);
    }

    function burn(uint256 tokenId) public override {
        _revoke(tokenId);
    }

    function _revoke(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);

        if (owner != _msgSender()) {
            revert TokenNotOwned(_msgSender(), tokenId);
        }

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Revoke(owner, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC4973).interfaceId;
    }
}
