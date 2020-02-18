pragma solidity 0.6.1;

import "./Ballot.sol";

/**
 * @title BallotList
 * @dev stores votings
 */
library BallotList {
    using BallotType for BallotType.Ballot;

    struct List {
        BallotType.Ballot[] list;
    }

    struct BallotSimple {
        uint starterGroupId;
        uint endTime;
        address starterAddress;
        uint questionId;
        bytes data;
    }

    /**
     * @dev add voting to list
     * @param _votingPrimary voting primary info
     * @return id
     */
    function add(
        List storage _self,
        BallotSimple memory _votingPrimary
    )
        internal
        returns (uint id)
    {
        BallotType.Ballot memory _voting = BallotType.Ballot({
            startBlock: block.number,
            startTime: block.timestamp,
            endTime: _votingPrimary.endTime,
            starterGroupId: _votingPrimary.starterGroupId,
            starterAddress: _votingPrimary.starterAddress,
            questionId: _votingPrimary.questionId,
            status: BallotType.BallotStatus.ACTIVE,
            result: BallotType.BallotResult.NOT_ACCEPTED,
            votingData: _votingPrimary.data
        });

        _self.list.push(_voting);
        return _self.list.length - 1;
    }


    /**
     * @dev checks id existance
     * @param _id id
     * @return valid
     */
    function checkId(
        List storage _self,
        uint _id
    )
        internal
        view
        returns (bool valid)
    {
        return _self.list.length > _id;
    }
}
