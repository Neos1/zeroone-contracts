pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/Ballots/Ballots.sol";

contract BallotsMock is Ballots {
  bytes public formula = hex"0041c8a92378323f33fc30b0a10e3fd771eb8f6dff010006010032320704000904000000";

  function testAddVoting(
     BallotList.BallotSimple memory _votingPrimary
  )
    public
  {
    _votingPrimary.endTime = block.timestamp + 36000;
    addVoting(
      _votingPrimary, 
      formula, 
      msg.sender
    );
  }


  function testCloseVoting()
    public
  {
    closeVoting(0, formula, msg.sender);
  }
}