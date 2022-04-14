// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./YourToken.sol";

contract NFT is ERC721Enumerable, Ownable {
    YourToken token;

    using Strings for uint256;

    string          baseURI = "https://bit-rush.com/punkins/";
    address public  addr_NFT_owner;
    string  public  baseExtension = ".json";

    // uint256 public  tokensPerEth = 100;         //ERC20 costs 0.01 eth
    // uint256 public  costOfOneNFTinToken = 2;    //NFT costs 2 ERC20
    uint256 public  cost = 1;                   //NFT costs 0.02 ETH

    uint256 public  maxSupply = 10000;
    uint256 public  maxMintAmount = 20;
    bool    public  paused = false;

    constructor(
        address _address_of_ERC20_contract
    ) ERC721("V", "V") {
        token = YourToken(_address_of_ERC20_contract);
        setOwner(msg.sender);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function ballance() public view returns (uint256) {
        return token.totalSupply();
    }

    function buyTokens(uint256 amountToBuy) public returns (uint256 tokenAmount) {
        uint256 allCost = amountToBuy * cost;
        // console.log(allCost);

        require(allCost <= token.balanceOf(msg.sender), "Not enough balance of ERC20");

        token.transferFrom(msg.sender, addr_NFT_owner, allCost);
        mint(amountToBuy);

        return amountToBuy;
    }

    // public
    function mint(uint256 _mintAmount) public {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != owner()) {
            require(token.balanceOf(msg.sender) >= cost * _mintAmount);
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setOwner(address _owner) public onlyOwner {
        addr_NFT_owner = _owner;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}