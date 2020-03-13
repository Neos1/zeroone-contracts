pragma solidity 0.6.1;

import "./Ballot.sol";
import "zeroone-voting-vm/contracts/ZeroOneVM.sol";


/**
 * @title BallotList
 * @dev stores votings
 */
library BallotList {
    using BallotType for BallotType.Ballot;

    struct List {
        BallotType.Ballot[] list;
        mapping(uint => ZeroOneVM.Ballot) descriptors;
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
        BallotType.Ballot memory _voting = BallotType.Ballot(
            block.number,
            block.timestamp,
            _votingPrimary.endTime,
            _votingPrimary.starterGroupId,
            _votingPrimary.starterAddress,
            _votingPrimary.questionId,
            BallotType.BallotStatus.ACTIVE,
            _votingPrimary.data
        );

        _self.list.push(_voting);
        id = _self.list.length - 1;
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
