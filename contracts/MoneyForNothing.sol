pragma solidity ^0.4.24;

contract MoneyForNothing {

  /************ Variables ************/
  // bool public isBetOpen;
  address public winnerAddress;
  // mapping betwing contributors and their bet (amount in ETH)
  // mapping (address => uint) public contributorsList;
  Contributor[] public contributorsList;
  uint public startTime;
  // Number of blocks during which users can bet
  uint public stopTime;
  // Number of blocks after stopTime to retrieved hash of blocks (used by random function)
  uint public constant drawTime = 1;
  // Number of blocks after drawTime before opening windraw (security time)
  uint public constant resultTime = 1;
  uint public findWinnerTime;
  uint public pot;
  // Percentage of total pot redistributed to the next round
  uint public redistributionPercentage;

  address public owner;
  uint public betDuration;

  uint private totalBlockHash;

  /************ Structs ************/
  struct Contributor{
    address myAddress;
    uint amountBet;
  }

  /************ Functions ************/
  function MoneyForNothing(uint newBetDuration, uint newRedistributionPercentage){
    owner = msg.sender;
    betDuration = newBetDuration;
    redistributionPercentage = newRedistributionPercentage;
    startTime = now;
    stopTime = startTime + betDuration;
    findWinnerTime = 0;
  }

  function initBet() private {
    startTime = now;
    stopTime = startTime + betDuration;
    findWinnerTime = 0;
    delete contributorsList;
    winnerAddress = 0x0000000000000000000000000000000000000000;
  }

  function bet() public payable{
    require(stopTime > now, "Bets are finished");
    require(msg.value > 0, "You must bet at least one wei");
    contributorsList.push(Contributor({
      myAddress: msg.sender,
      amountBet: msg.value
    }));
    pot = pot + msg.value;
  }

  // TODO: manage the weighting
  function findWinner() public {
    require(stopTime + drawTime < now, "Too early, whait some blocks");
    require(winnerAddress == 0x0000000000000000000000000000000000000000, "A winner is already selected");
    findWinnerTime = now;
    // Find winner: Get last ten blockhash, add and convert into uint248. Then get the modulo of contributorsList array to get the winner.
    if(contributorsList.length > 0){
      for (uint i = 1; i < 11; i++){
          totalBlockHash = totalBlockHash + uint248(block.blockhash(block.number - i));
          winnerAddress = contributorsList[totalBlockHash % (contributorsList.length)].myAddress;
      }
    }else{
      // If nobody has participated during this round, we launch a new round
      initBet();
    }
  }

  function payWinner() public {
    require(findWinnerTime != 0, "Launch findWinner first");
    require(winnerAddress != 0x0000000000000000000000000000000000000000, "There is no winner selected");
    require(findWinnerTime + resultTime < now, "Too early, whait some blocks");
    if(pot > 0){
      winnerAddress.transfer(pot*(100-redistributionPercentage)/100);
      pot = pot - pot*(100-redistributionPercentage)/100;
    }
    // Relaunch the process
    initBet();
  }

  function getContractBalance() public returns(uint){
    return this.balance;
  }

  // TODO:
  // getNbBlockLeftBeforeNextStep
}
