// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    // for getting tokenURI = _baseTokenURI+TokenId
    string _baseTokenURI;
    // price of an NFT
    uint256 public _price = 0.01 ether;
    //  to pause contract if necessary
    bool public _paused;
    // max 20 tokens can be minted
    uint256 public maxTokenIds = 20;
    // current minted id
    uint256 public tokenIds;
    // Instance of whitelist contract
    IWhitelist whitelist;
    // keep track of presale Started
    bool public presaleStarted;
    // timestamp to end presale
    uint256 public presaleEnded;
    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract)
        ERC721("Crypto Devs", "CD")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "Presale is not running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "You are not whitelisted"
        );
        require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && block.timestamp > presaleEnded,
            "Presale has not ended yet"
        );
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether  sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    // ERC721 default gives empty string when it's called
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Receive, msg.data == empty
    receive() external payable {}

    // Fallback , msg.data != empty
    fallback() external payable {}
}
