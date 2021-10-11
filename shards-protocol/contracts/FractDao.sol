//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

import "./Settings.sol";

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
    struct vault{
        string name;
        string symbol;
        address tokenAddress;
        uint256 tokenId;
        uint256 supply;
        address newErc20Token;

    }

    Settings private settings;
    mapping(address => vault) public records;

    address[] private _activeAddresses;
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
    }

    modifier onlyGovernors {
      require(balanceOf(msg.sender) > 0);
      _;
    }

    // compile active addresses - for accounts just about to receive tokens
    function _addActiveAddress(address account) internal {
        if (balanceOf(account) == 0) {
          _activeAddresses.push(account);
        }
    }

    //mint FDAO supply
    function mintfdao(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
        votingCost = totalSupply() / 1000; // starting a vote costs 0.1% of total supply
        _addActiveAddress(account);
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
        records[msg.sender] = vault(_name, _symbol, _token, _id, _supply, address(_newToken));

        return address(_newToken);
    }

    function onERC721Received(address _operator,address _from,uint256 _tokenId,bytes calldata _data) external pure returns(bytes4){
        return this.onERC721Received.selector;
    }

    function _beforeTokenTransfer(address sender, address recipient, uint amount) internal override{
        _addActiveAddress(recipient); // sender should already be recorded by the logic
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
        settings.updateMaxSupply(_topVotedSupply);
        emit supplyUpdated(_topVotedSupply);
    }
}
