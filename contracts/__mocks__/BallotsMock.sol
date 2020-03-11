pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/Ballots/Ballots.sol";

contract BallotsMock is Ballots {
  bytes formula = "0x0041c8a92378323f33fc30b0a10e3fd771eb8f6dff010006010032320704000904000000";

  function testAddVoting(
     BallotList.BallotSimple memory _votingPrimary
  )
    public
  {
    addVoting(
      _votingPrimary, 
      formula, 
      0x41c8a92378323F33FC30B0a10E3fd771Eb8f6DFf
    );
  }
  function testCloseVoting()
    public
  {
    closeVoting(0, formula, 0x41c8a92378323F33FC30B0a10E3fd771Eb8f6DFf);
  }
}