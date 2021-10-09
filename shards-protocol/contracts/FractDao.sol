//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "./Settings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract newToken is ERC20 {
    
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
       
    }
    
    
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract FractDao is Ownable{
    Settings private settings;
    mapping(address=>vault) records;
    
    struct vault{
        string name;
        string symbol;
        address tokenAddress;
        uint256 tokenId;
        uint256 supply;
        
    }
    constructor(address _settings) {
        settings = Settings(_settings);
    }
    
    
    //mint function
    function mint(string memory _name, string memory _symbol, address _token, uint256 _id, uint256 _supply) external returns(bool) {
    require(_supply <= settings.maxSupply(), "Supply is greater than allowed");
    
    //transfer ERC721 to the contract
    IERC721(_token).safeTransferFrom(msg.sender, address(this), _id);
    
    //create new ERC20s with respective info
    newToken _newToken = new newToken(_name, _symbol);
    _newToken.mint(address(this), _supply);
    
    //recordkeeping
    records[msg.sender] = vault(_name, _symbol, _token, _id, _supply);
    
    return true;
    }
    
    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes calldata _data) external pure returns(bytes4){
        return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
    }
}


