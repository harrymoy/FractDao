//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// tracks activeAddresses
contract Vault is ERC20 {
    address[] public activeAddresses;
    struct strVault{
        address creator;
        string name;
        string symbol;
        address tokenAddress;
        uint256 tokenId;
        uint256 supply;
    }

    address public creator;
    uint public maxSupply;
    address public nftAddress;
    uint public nftTokenId;

    constructor(string memory name_, string memory symbol_, address _creator, uint _supply, address _token, uint _token_id, uint _max_supply)
        ERC20(name_, symbol_)
    {
      require(_supply < _max_supply);
      _mint(_creator, _supply);
      _addActiveAddress(_creator);

      creator = _creator;
      maxSupply = _max_supply;
      nftAddress = _token;
      nftTokenId = _token_id;
    }

    function getActiveAddresses() public view returns (address[] memory) {
      return activeAddresses;
    }

    // compile active addresses - for accounts just about to receive tokens
    function _addActiveAddress(address account) internal {
        if (balanceOf(account) == 0) {
          activeAddresses.push(account);
        }
    }

    function _beforeTokenTransfer(address, address recipient, uint) internal override{
        _addActiveAddress(recipient); // sender should already be recorded by the logic
    }

    function mint(address account, uint256 amount) public {
        require(totalSupply() + amount < maxSupply);
        _mint(account, amount);
        _addActiveAddress(account);
    }
}
