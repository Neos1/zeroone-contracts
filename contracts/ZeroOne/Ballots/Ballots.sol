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
     */
    function getVoting(
        uint _id
    )
        public
        view
        ballotExist(_id)
        returns (
            uint startTime,
            uint starterGroupId,
            uint starterAddress,
            uint questionId,
            BallotType.BallotStatus status,
            BallotType.BallotResult result,
            bytes memory votingData
        )
    {
        return ballots.list[_id].getPrimaryInfo();
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

    function setVote(
        address _group,
        address _user,
        BallotType.BallotResult _descision,
        uint256 _voteWeight
    ) 
        public
        returns (bool success)
    {
        uint votingId = ballots.list.length - 1;
        
        require(
            ballots.list[votingId].status != BallotType.BallotStatus.CLOSED, 
            "Voting is closed, you must start new voting before vote"
            );
        ballots.list[votingId].setVote(_group, _user, _descision, _voteWeight);
        return true;
    }

    /**
     * @dev closes last voting in list
     * @return result
     */
    function closeVoting() 
        public
        returns (
            BallotType.BallotResult result
        )
    {
        uint votingId = ballots.list.length - 1;
        return ballots.list[votingId].closeVoting();
    }
}
