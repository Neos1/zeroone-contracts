pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/Ballot.sol";
import "./lib/BallotList.sol";

/**
 * @title Ballots
 * @dev stores Ballots
 */
contract Ballots {
    using BallotList for BallotList.List;
    using BallotType for BallotType.Ballot;

    BallotList.List ballots;

    event VotingStarted(uint votingId, uint questionId);

    event VotingEnded(uint votingId, BallotType.BallotResult descision);

    event UserVote(address group, address user, BallotType.BallotResult descision);

    /**
     * @notice reverts on non-existing ballot id
     * @param _id ballot id
     */
    modifier ballotExist(
        uint _id
    ) {
        require(
            ballots.checkId(_id),
            "Provided index out of bounds"
        );
        _;
    }

    constructor() public {}

    /**
     * @dev getting the voting by id
     * @return ballot
     */
    function getVoting(
        uint _id
    )
        public
        view
        ballotExist(_id)
        returns (BallotType.Ballot memory ballot)
    {
        // TODO: Return primary voting info (mapping error); 
        return ballots.list[_id];
    }

    /**
     * @dev return amount of votings
     * @return amount
     */
    function getVotingsAmount()
        public
        view
        returns (uint amount)
    {
        return ballots.list.length;
    }

    function closeVoting() 
        public
    {
        uint votingId = ballots.list.length - 1;
        ballots.list[votingId].closeVoting();
    }
}
