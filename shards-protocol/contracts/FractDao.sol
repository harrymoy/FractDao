//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./Settings.sol";
import "./Voting.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { trackedERC20 } from "./trackedERC20.sol";

contract FractDao is Ownable, trackedERC20("FractDao", "FDAO"){
    struct Vault{
        address creator;
        string name;
        string symbol;
        address tokenAddress;
        uint256 tokenId;
        uint256 supply;
    }

    Settings private settings;
    mapping(address => mapping(uint => address)) public nftVaultMap;
    mapping(address=>Vault) public records;

    address[] public vaultAddresses;

    Voting private currentVote;
    event supplyUpdated(uint _new_supply);
    uint public voteEndBlock;
    uint public maxMintSupply;

    constructor(address _settings) {
        settings = Settings(_settings);
        activeAddresses.push(address(0)); // the remove function seems to only work if index is > 0?
        maxMintSupply = settings.maxSupply();
    }

    modifier onlyGovernors {
      require(balanceOf(msg.sender) > 0);
      _;
    }

    modifier onlyNonVoters {
      if (block.timestamp < voteEndBlock) {
        require(currentVote.votability(msg.sender), "CT"); // Cannot transact until voting period ends
      }
      _;
    }

    //mint FDAO supply
    function mintfdao(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
        _addActiveAddress(account);
    }

    function getAllVaults() external returns(address[] memory) {
        return vaultAddresses;
    }

    function getVault(address _token, uint256 _id) external returns(address) {
      return nftVaultMap[_token][_id];
    }


    //mint function for client
    function mint(string memory _name, string memory _symbol, address _token, uint256 _id, uint256 _supply) external returns(address) {
        require(_supply <= settings.maxSupply(), "SG"); // Supply Greater than allowed

        //transfer ERC721 to the contract
        //IERC721(_token).setApprovalForAll(address(this), true);
        IERC721(_token).safeTransferFrom(msg.sender, address(this), _id);

        //create new ERC20s with respective info
        trackedERC20 _newToken = new trackedERC20(_name, _symbol);
        _newToken.mint(msg.sender, _supply);

        //transfer token to user
        //_newToken.transfer(msg.sender, _supply);

        //recordkeeping
        records[address(_newToken)] = Vault(msg.sender, _name, _symbol, _token, _id, _supply); // changed records otherwise a user can only create 1 vault per wallet
        vaultAddresses.push(address(_newToken));
        nftVaultMap[_token][_id] = address(_newToken);

        return address(_newToken);
    }

    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes calldata _data) external pure returns(bytes4){
        return this.onERC721Received.selector;
    }


    function transfer(address recipient, uint256 amount) public override onlyNonVoters returns (bool) {
        return super.transfer(recipient, amount);
    }

    // Governance - vote to increase max. supply

    function startVote() public onlyGovernors {
        // burn X amount of governance tokens so voting isn't somehow abused in addition to gas cost of deploying a contract
        require(block.timestamp > voteEndBlock); // require previous voting round to end before starting a new vote
        _burn(msg.sender, totalSupply() / 1000); // starting a vote costs 0.1% of total supply
        currentVote = new Voting(maxMintSupply);
        voteEndBlock = block.timestamp + 70000; // currently, it is ~6500 blocks/day, so this is about 11 days
    }

    function vote(uint _supply) public onlyGovernors {
        require(block.timestamp <= voteEndBlock);
        currentVote.vote(msg.sender, _supply);
    }

    function endVote() public onlyGovernors {
        require(block.timestamp > voteEndBlock);
        uint result = currentVote.endVote(totalSupply() * 4 / 10); // at least 40% of token holders agree

        if (result != maxMintSupply) {
          // How it affects current holders
          for (uint i=0; i<vaultAddresses.length; i++) {
              _adjustSupply(vaultAddresses[i], maxMintSupply, result);
          }
          settings.updateMaxSupply(result);
          emit supplyUpdated(result);
        }
    }

    function _adjustSupply(address _vaultAdd, uint _old_supply, uint _new_supply) internal {
        trackedERC20 _vault = trackedERC20(_vaultAdd);
        address[] memory _allAdds = _vault.getActiveAddresses();
        for (uint i=0; i<_allAdds.length; i++) {
          address _acc = _allAdds[i];
          _vault.mint(_acc, (_vault.balanceOf(_acc) * _new_supply / _old_supply) - _vault.balanceOf(_acc));
        }
    }
}
