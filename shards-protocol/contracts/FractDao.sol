//SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract FractDao is Ownable{
    address public immutable settings;
    
    constructor(address _settings) {
        settings = _settings;
    }
    
    
    //mint function
    function mint(string memory _name, string memory _symbol, address _token, uint256 _id, uint256 _supply, uint256 _listPrice) external returns(bool) {
    //require(_supply <= settings.maxSupply, "Supply is greater than allowed");
    

    
    
    
    //create a vault of ERC20s with respective info

    return true;
    }
}


