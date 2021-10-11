//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "./Settings.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract newToken is ERC20 {

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {

    }


    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}

contract FractDao is Ownable, ERC20("FractDao", "FDAO"){
    struct Vault{
        string name;
        string symbol;
        address tokenAddress;
        uint256 tokenId;
        uint256 supply;
        address newErc20Token;

    }

    Settings private settings;
    mapping(address=>Vault) public records;


    constructor(address _settings) {
        settings = Settings(_settings);
    }
    //mint FDAO supply
    function mintfdao(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    //mint function for client
    function mint(string memory _name, string memory _symbol, address _token, uint256 _id, uint256 _supply) external returns(address) {
        require(_supply <= settings.maxSupply(), "Supply is greater than allowed");

        //transfer ERC721 to the contract
        //IERC721(_token).setApprovalForAll(address(this), true);
        IERC721(_token).safeTransferFrom(msg.sender, address(this), _id);

        //create new ERC20s with respective info
        newToken _newToken = new newToken(_name, _symbol);
        _newToken.mint(msg.sender, _supply);

        //transfer token to user
        //_newToken.transfer(msg.sender, _supply);

        //recordkeeping
        records[msg.sender] = Vault(_name, _symbol, _token, _id, _supply, address(_newToken));

        return address(_newToken);
    }

    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes calldata _data) external pure returns(bytes4){
        return this.onERC721Received.selector;
    }

    function getVaultforNft(address _nftAddress) public returns(Vault) {
        Vault vault = records[_nftAddress];
        return vault; 
    }

    // Governance - vote to increase max. supply
    //function vote(ad
}
