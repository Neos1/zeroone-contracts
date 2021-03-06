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

    function didUserVote(address project, address user) external returns(bool); 

    function getUserVoteWeight(address tokenAddr, address user) external view returns(uint256);

    function getUserVote(address tokenAddr, address user) external view returns(uint);
    
    function submitVoting() external;
    
    function setGroupAdmin(address tokenAddr, address newOwner) external;
}
