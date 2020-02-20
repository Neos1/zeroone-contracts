pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

/**
 * @title IZeroOne
 * @dev implements ZeroOne interface
 */
interface IZeroOne {
    enum Result {
        UNDEFINED,
        ACCEPTED,
        DECLINED
    }

    struct MetaData {
        uint ballotId;
        uint questionId;
        uint startBlock;
        uint endBlock;
        Result result;
    }

    function updateUserVote(address project, address user, uint256 newVoteWeight) external returns(bool);

    function isUserVoted(address project, address user) external returns(bool); 
}
