//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./Settings.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract newToken is ERC20 {
    address[] public activeAddresses;
    mapping(address => uint) private _indexOfAddress;

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
      activeAddresses.push(address(0)); // the remove function seems to only work if index is > 0?
    }

    function getActiveAddresses() public returns (address[] memory) {
      return activeAddresses;
    }

    // compile active addresses - for accounts just about to receive tokens
    function _addActiveAddress(address account) internal {
        if (balanceOf(account) == 0) {
          activeAddresses.push(account);
          _indexOfAddress[account] = activeAddresses.length - 1;
        }
    }

    // See https://ethereum.stackexchange.com/questions/35790/efficient-approach-to-delete-element-from-array-in-solidity/41025
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

    function _beforeTokenTransfer(address sender, address recipient, uint amount) internal override{
        _addActiveAddress(recipient); // sender should already be recorded by the logic
    }

    function _afterTokenTransfer(address sender, address recipient, uint amount) internal override{
        _removeActiveAddress(sender); // sender should already be recorded by the logic
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
        _addActiveAddress(account);
    }
}

contract FractDao is Ownable, ERC20("FractDao", "FDAO"){
    struct vault{
        address creator;
        string name;
        string symbol;
        address tokenAddress;
        uint256 tokenId;
        uint256 supply;
        //address newErc20Token;
    }

    Settings private settings;
    mapping(address => vault) public records;
    mapping(address => mapping(uint => address)) public nftVaultMap;

    address[] public vaultAddresses;

    address[] private _activeAddresses;
    mapping(address => uint) private _indexOfAddress;
    mapping(address=>uint256) private _snapshot;
    mapping(address => bool)  private _votedList;
    mapping(uint=>uint) private _votes; // private or public? private lets people make decisions without getting influenced, but may result in a long time before votes actually work
    uint[] private _supplyVotedOn;
    uint private _topVotedSupply;
    uint private _mostVotesNumber;

    event voteReceived(address _voter, uint _num_votes);//, uint _supply);
    event supplyUpdated(uint _new_supply);
    uint public voteEndBlock;
    uint public votingCost;

    constructor(address _settings) {
        settings = Settings(_settings);
        _activeAddresses.push(address(0)); // the remove function seems to only work if index is > 0?
    }

    modifier onlyGovernors {
      require(balanceOf(msg.sender) > 0);
      _;
    }

    // compile active addresses - for accounts just about to receive tokens
    function _addActiveAddress(address account) internal {
        if (balanceOf(account) == 0) {
          _activeAddresses.push(account);
          _indexOfAddress[account] = _activeAddresses.length - 1;
        }
    }

    // See https://ethereum.stackexchange.com/questions/35790/efficient-approach-to-delete-element-from-array-in-solidity/41025
    function _removeActiveAddress(address account) internal {
      if (balanceOf(account) == 0) {
        uint index = _indexOfAddress[account];
        if (index == 0) return;

        if (_activeAddresses.length > 1) {
          _activeAddresses[index] = _activeAddresses[_activeAddresses.length-1];
        }
        delete _activeAddresses[_activeAddresses.length - 1]; // recovers gas from last element storage

        _indexOfAddress[account] = 0;
      }
    }



    //mint FDAO supply
    function mintfdao(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
        votingCost = totalSupply() / 1000; // starting a vote costs 0.1% of total supply
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
        records[address(_newToken)] = vault(msg.sender, _name, _symbol, _token, _id, _supply); // changed records otherwise a user can only create 1 vault per wallet
        vaultAddresses.push(address(_newToken));
        nftVaultMap[_token][_id] = address(_newToken);

        return address(_newToken);
    }

    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes calldata _data) external pure returns(bytes4){
        return this.onERC721Received.selector;
    }

    function _beforeTokenTransfer(address sender, address recipient, uint amount) internal override{
        _addActiveAddress(recipient); // sender should already be recorded by the logic
    }

    function _afterTokenTransfer(address sender, address recipient, uint amount) internal override{
        _removeActiveAddress(sender); // sender should already be recorded by the logic
    }

    // Governance - vote to increase max. supply
    function startVote() public onlyGovernors {
        // burn X amount of governance tokens so voting isn't somehow abused
        require(block.timestamp > voteEndBlock); // require previous voting round to end before starting a new vote
        _burn(msg.sender, votingCost);

        voteEndBlock = block.timestamp + 70000; // currently, it is ~6500 blocks/day, so this is about 11 days

        _topVotedSupply = settings.maxSupply();
        _mostVotesNumber =  0;

        for (uint i=0; i<_activeAddresses.length; i++) {
            _snapshot[_activeAddresses[i]] = balanceOf(_activeAddresses[i]);
            _votedList[_activeAddresses[i]] = false;
        }

        for (uint i = 0; i < _supplyVotedOn.length; i++) {
            _votes[_supplyVotedOn[i]] = 0;
        }
        delete _supplyVotedOn;

    }

    function vote(uint _supply) public onlyGovernors {
        require(block.timestamp <= voteEndBlock);
        require(settings.maxSupply() <= _supply);
        require(!_votedList[msg.sender]); // for now, can only vote once per voting event

        _votedList[msg.sender] = true; // check-effects-interaction pattern

        if (_votes[_supply] == 0) {
          _supplyVotedOn.push(_supply);
        }
        _votes[_supply] += _snapshot[msg.sender];
        if (_votes[_supply] > _mostVotesNumber) {
          _mostVotesNumber = _votes[_supply];
          _topVotedSupply = _supply;
        }

        emit voteReceived(msg.sender, _snapshot[msg.sender]);
    }

    function endVote() public onlyGovernors {
        require(block.timestamp > voteEndBlock);
        require(_mostVotesNumber > (totalSupply() * 4 / 10)); // at least 40% of token holders agree

        // How it affects current holders
        for (uint i=0; i<vaultAddresses.length; i++) {
            _adjustSupply(vaultAddresses[i], settings.maxSupply(), _topVotedSupply);
        }

        settings.updateMaxSupply(_topVotedSupply);
        emit supplyUpdated(_topVotedSupply);
    }

    function _adjustSupply(address _vaultAdd, uint _old_supply, uint _new_supply) internal {
        newToken _vault = newToken(_vaultAdd);
        address[] memory _allAdds = _vault.getActiveAddresses();
        for (uint i=0; i<_allAdds.length; i++) {
          address _acc = _allAdds[i];
          _vault.mint(_acc, (_vault.balanceOf(_acc) * _new_supply / _old_supply) - _vault.balanceOf(_acc));
        }
    }
}
