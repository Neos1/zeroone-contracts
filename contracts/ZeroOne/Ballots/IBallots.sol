pragma solidity 0.6.1;


interface IBallots {

    function updateUserVote(address tokenAddress, address user, uint256 newVoteWeight) external returns(bool);

    function didUserVote(uint votingId, address project, address user) external returns(bool); 

    function getUserVoteWeight(uint votingId, address tokenAddr, address user) external view returns(uint256);

    function getUserVote(uint votingId, address tokenAddr, address user) external view returns(uint);

    function submitVoting() external;

    function setGroupAdmin(address tokenAddr, address newOwner) external;
}