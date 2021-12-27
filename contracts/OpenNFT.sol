//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract OpenNFT is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    uint256 public constant MAX_SUPPLY = 10_000;
    IERC20 public constant SOS =
        IERC20(0x3b484b82567a09e2588A13D54D032153f0c0aEe0);
    uint256 public sosCost = 1_000;
    string _tokenBaseURI;
    Counters.Counter _tokenIdCounter;
    mapping(uint256 => string) _tokenURIs;

    constructor() ERC721("OpenNFT", "OPEN") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _baseURI() internal view override returns (string memory) {
        return _tokenBaseURI;
    }

    function safeMint() external {
        require(
            _tokenIdCounter.current() <= MAX_SUPPLY,
            "Max supply has been reached"
        );
        require(SOS.balanceOf(msg.sender) >= sosCost, "Not enough SOS");
        // user must approve SOS transfers from contract first
        require(
            SOS.allowance(msg.sender, address(this)) >= sosCost,
            "Not enough SOS approved"
        );
        // prevent sybil attacks from scripts/contracts/etc. - see what happened to Adidas
        // link: https://jbecker.dev/research/adidas-originals/
        require(tx.origin == msg.sender, "Only users can mint");
        SOS.transferFrom(msg.sender, address(this), sosCost);
        _safeMint(msg.sender, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function setBaseURI(string calldata baseURI)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _tokenBaseURI = baseURI;
    }

    function setSOSCost(uint256 cost) public onlyRole(DEFAULT_ADMIN_ROLE) {
        sosCost = cost;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
