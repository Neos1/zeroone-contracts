pragma solidity 0.6.1;


interface IBallots {
    function updateUserVote(address tokenAddress, address user, uint256 newVoteWeight) external returns(bool);
}