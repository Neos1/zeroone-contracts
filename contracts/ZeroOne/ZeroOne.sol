pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./IZeroOne.sol";
import "./Notifier/Notifier.sol";
import "../lib/Meta.sol";
import "./Ballots/Ballots.sol";



/**
 * @title ZeroOne
 * @dev main ZeroOne contract
 */
contract ZeroOne is Notifier, IZeroOne, Ballots {
    using Meta for bytes;

    /**
     * @notice for modified functions allows only self external call
     */
    modifier onlySelf {
        require(
            msg.sender == address(this),
            "Only self call is possible"
        );
        _;
    }

    /**
     * @dev closes last voting in list
     * @return descision
     */
    function closeVoting() 
        public
        returns (
            BallotType.BallotResult descision
        )
    {
        uint votingId = ballots.list.length - 1;
        require(ballots.list[votingId].endTime < block.timestamp, "Time is not over yet");
        descision = ballots.list[votingId].closeVoting();
        uint questionId = ballots.list[votingId].questionId;

        MetaData memory meta = MetaData({
            ballotId: votingId,
            questionId: questionId,
            startBlock: ballots.list[votingId].startBlock,
            endBlock: block.number,
            result: Result.ACCEPTED
        });

        makeCall(
            questions.list[questionId].target, 
            questions.list[questionId].methodSelector, 
            ballots.list[votingId].votingData,
            meta
        );
        emit VotingEnded(votingId, descision);
    }

    /**
     * @notice makes call to contract external method
     * with modified data (meta added)
     * @param _target contract address to make call to
     * @param _method method selector
     * @param _data data to provide with call
     * @param _metaData meta to update data
     * @return result
     */
    function makeCall(
        address _target,
        bytes4 _method,
        bytes memory _data,
        MetaData memory _metaData
    )
        internal
        returns (bool result)
    {
        return notify(
            _target,
            _method,
            _data.addMetaData(abi.encode(_metaData))
        );
    }
}
