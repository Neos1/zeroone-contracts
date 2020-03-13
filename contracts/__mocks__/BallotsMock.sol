pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/Ballots/Ballots.sol";

/**
 * @title BallotsMock
 * @dev Mock for testing Ballots contract
 */
contract BallotsMock is Ballots {
    bytes public formula = hex"00BEF946538A29B7c330F6a77f61c5C1c8735a8ace010006010032320704000904000000";
    address owners = 0xBEF946538A29B7c330F6a77f61c5C1c8735a8ace;

    /**
     * @dev method for testing "addVoting" method in Ballots
     * @param _votingPrimary primary info about voting
     */
    function testAddVoting(
        BallotList.BallotSimple memory _votingPrimary
    )
        public
    {
        _votingPrimary.endTime = block.timestamp + 36000;
        addVoting(
            _votingPrimary, 
            formula, 
            owners
        );
    }

    /**
     * @dev method for testing "closeVoting" method in Ballots
     */
    function testCloseVoting()
        public
    {
        closeVoting(0, formula, msg.sender);
    }
    }