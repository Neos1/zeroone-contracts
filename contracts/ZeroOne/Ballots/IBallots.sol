pragma solidity 0.6.1;


interface IBallots {

    function updateUserVote(address project, address user, uint256 newVoteWeight) external returns(bool);

    function didUserVote(address project, address user) external returns(bool); 

    function getUserVoteWeight(uint votingId, address tokenAddr, address user) external view returns(uint256);

    function getUserVote(address tokenAddr, address user) external view returns(uint);

    function submitVoting() external;

    function setGroupAdmin(address tokenAddr, address newOwner) external;
}