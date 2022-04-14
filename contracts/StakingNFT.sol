// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NFT.sol";

contract StakingNFT {
    
    struct _NFT { 
        address NFT_owner;
        bool active_token;
        uint256 start_time;
   }

    // uint256 private maxStakingAmount = 1;

    mapping(address /* owner's address */ => mapping(uint256 /* id */ => _NFT)) public NFT_storage;

    // -_-_-_-_-_-_-_-_-_-_-_-_
    address address_of_this_contract;
    address owner;

    // -_-_-_-_-_-_-_-_-_-_-_-_
    uint256 period = 5 /* second = 1 day */;
    uint256 rewardPerPeriod = 1 /* 1 * 10 ** -18 of ERC20 token */;
    uint256 RewardPool = 0;

    // -_-_-_-_-_-_-_-_-_-_-_-_
    YourToken token;
    NFT nft_token;
    address ERC20_contr_address;
    address NFT_contr_address;

    modifier RewardPoolNotNull() {
        require(RewardPool > 0, "Award pool is NULL, owner need to top up his contract");
        _;
    }

    // unused modifier
    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == address_of_this_contract, "Only owner can do this action");
        _;
    }
    
    // we throw Tokens from some ERC20 holder address
    // on the address of this Staking Contract, and then
    // increase RewardPool  
    constructor(address _address_of_ERC20_contract /* ERC20 */,address _address_of_NFT_contract /* NFT */) {
        address_of_this_contract = address(this);
        owner = msg.sender;

        setERC20_address(_address_of_ERC20_contract);
        setNFT_address(_address_of_NFT_contract);
        token = YourToken(_address_of_ERC20_contract);
        nft_token = NFT(_address_of_NFT_contract);
    }

    function makeRewardPool(uint256 _RewardPool) external {
        // but before allowance
        token.transferFrom(owner, address_of_this_contract, _RewardPool);
        RewardPool = _RewardPool;
    }

    function stake(uint id) external RewardPoolNotNull() {
        _NFT memory nft;
        nft.NFT_owner = msg.sender;
        nft.active_token = true;
        nft.start_time = block.timestamp;
        NFT_storage[msg.sender][id] = nft;

        // but before we need to approve transfer from our address to this contract address
        nft_token.transferFrom(msg.sender, address_of_this_contract, id);   // transfer from our address to address of
                                                                            // staking contract
    }

    function unstake(uint id) external RewardPoolNotNull() {
        // reward
        uint256 amount = (block.timestamp - NFT_storage[msg.sender][id].start_time) / period * rewardPerPeriod;
        token.transfer(msg.sender, amount);
        RewardPool -= amount;

        // transfer of token
        nft_token.transferFrom(address_of_this_contract, msg.sender, id);
        delete NFT_storage[msg.sender][id];
    }

    function getRewardPool() external view returns (uint256) {
        return RewardPool;
    }

    function setERC20_address(address _ERC20_contr_address) onlyOwner() public {
        ERC20_contr_address = _ERC20_contr_address;
    }

    function setNFT_address(address _NFT_contr_address) onlyOwner() public {
        NFT_contr_address = _NFT_contr_address;
    }
}