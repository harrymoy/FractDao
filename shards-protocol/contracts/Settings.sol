//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Settings is Ownable{
    uint public maxSupply;
    
    constructor() {
        maxSupply = 10;
    }
    
    function updateMaxSupply(uint _newSupply) external onlyOwner {
        maxSupply = _newSupply;
    }
    
    
}