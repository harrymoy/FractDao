//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// tracks activeAddresses
contract trackedERC20 is ERC20 {
    address[] public activeAddresses;
//    mapping(address => uint) private _indexOfAddress;

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
      activeAddresses.push(address(0)); // the remove function seems to only work if index is > 0?
    }

    function getActiveAddresses() public view returns (address[] memory) {
      return activeAddresses;
    }

    // compile active addresses - for accounts just about to receive tokens
    function _addActiveAddress(address account) internal {
        if (balanceOf(account) == 0) {
          activeAddresses.push(account);
//          _indexOfAddress[account] = activeAddresses.length - 1;
        }
    }

/*    // See https://ethereum.stackexchange.com/questions/35790/efficient-approach-to-delete-element-from-array-in-solidity/41025
    function _removeActiveAddress(address account) internal {
      if (balanceOf(account) == 0) {
        uint index = _indexOfAddress[account];
        if (index == 0) return;

        if (activeAddresses.length > 1) {
          activeAddresses[index] = activeAddresses[activeAddresses.length-1];
        }
        delete activeAddresses[activeAddresses.length - 1]; // recovers gas from last element storage

        _indexOfAddress[account] = 0;
      }
    }
*/
    function _beforeTokenTransfer(address, address recipient, uint) internal override{
        _addActiveAddress(recipient); // sender should already be recorded by the logic
    }
/*
    function _afterTokenTransfer(address sender, address recipient, uint amount) internal override{
        _removeActiveAddress(sender); // sender should already be recorded by the logic
    }
*/
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
        _addActiveAddress(account);
    }
}
