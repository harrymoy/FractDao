//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./FractDao.sol";

contract Voting is Ownable{

  mapping(address => bool)  private _votedList;
  mapping(uint=>uint) private _votes; // private or public? private lets people make decisions without getting influenced, but may result in a long time before votes actually work
  uint[] private _supplyVotedOn;
  address[] private _activeAddresses;
  uint private _topVotedSupply;
  uint private _mostVotesNumber;
  uint private _oldSupply;
  event voteReceived(address _voter, uint _num_votes);

  FractDao private dao;

  constructor(uint __oldSupply) {
    dao = FractDao(msg.sender);
    _activeAddresses = dao.getActiveAddresses();
    _oldSupply = __oldSupply;
    _topVotedSupply = __oldSupply;

  }

  function vote(address account, uint _supply) public onlyOwner {
    require(!_votedList[account], "AV"); // Already Voted (for now, can only vote once per voting event)
    require(_oldSupply <= _supply, "CRS"); // Cannot reduce supply
    _votedList[account] = true; // check-effects-interaction pattern

    if (_votes[_supply] == 0) {
      _supplyVotedOn.push(_supply);
    }
    _votes[_supply] += dao.balanceOf(account);
    if (_votes[_supply] > _mostVotesNumber) {
      _mostVotesNumber = _votes[_supply];
      _topVotedSupply = _supply;
    }

    emit voteReceived(account, dao.balanceOf(account));
  }

  function endVote(uint _limit) public onlyOwner returns(uint) {
    if (_mostVotesNumber > _limit) {
      return _topVotedSupply;
    }
    return _oldSupply;
  }

  function votability(address _acc) public returns(bool) {
    return !(_votedList[_acc]);
  }

}
