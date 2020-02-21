pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./IZeroOne.sol";
import "./Notifier/Notifier.sol";
import "../lib/Meta.sol";
import "./UserGroups/IERC20.sol";


/**
 * @title ZeroOne
 * @dev main ZeroOne contract
 */
contract ZeroOne is Notifier, IZeroOne {
    using Meta for bytes;

    enum BallotStatus { CLOSED, ACTIVE }

    enum BallotResult { NOT_ACCEPTED, POSITIVE, NEGATIVE }

    struct Ballot {
        uint startBlock;
        uint startTime;
        uint endTime;
        uint starterGroupId;
        address starterAddress;
        uint questionId;
        BallotStatus status;
        BallotResult result;
        bytes votingData;
        mapping(address => mapping(address => BallotResult)) votes;
        mapping(address => mapping(address => uint256)) votesWeight;
        mapping(address => mapping(uint => uint256)) descisionWeights;
    }

    Ballot ballot;

    constructor() public {
        ballot = Ballot({
            startBlock: block.number,
            startTime: block.timestamp,
            endTime: block.timestamp + 36000,
            starterGroupId: 0,
            starterAddress: msg.sender,
            questionId: 1,
            status: BallotStatus.ACTIVE,
            result: BallotResult.NOT_ACCEPTED,
            votingData: "0x"
        });
    }

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


    function setVote(address tokenAddr, address user, BallotResult descision) public returns (BallotResult) {
        IERC20 token = IERC20(tokenAddr);
        uint256 tokenBalance = token.balanceOf(user);
        require(token.transferFrom(user, address(this), tokenBalance));
        ballot.votes[tokenAddr][user] = descision;
        ballot.votesWeight[tokenAddr][user] = tokenBalance;
    }

    function updateUserVote(address tokenAddr, address user, uint256 newVoteWeight) public override returns(bool){
        uint256 oldVoteWeight = ballot.votesWeight[tokenAddr][user];
        uint index = uint(ballot.votes[tokenAddr][user]);
        uint256 oldDescisionWeight = ballot.descisionWeights[tokenAddr][index];

        if (ballot.status == BallotStatus.ACTIVE) {
            ballot.votesWeight[tokenAddr][user] = newVoteWeight;
            ballot.descisionWeights[tokenAddr][index] = oldDescisionWeight - oldVoteWeight + newVoteWeight;
            if (newVoteWeight == 0) {
                ballot.votes[tokenAddr][user] = BallotResult.NOT_ACCEPTED;
            }
        }
    }

    function getUserVote(address tokenAddr, address user) 
        public 
        view
        override
        returns(uint)
    {
        return uint(ballot.votes[tokenAddr][user]);
    }

    function getUserVoteWeight(address tokenAddr, address user) 
        public 
        view
        override
        returns(uint256)
    {
       return ballot.votesWeight[tokenAddr][user];
    }

    function isUserVoted(address tokenAddr, address user)
        public 
        override 
        returns(bool)
    {
        return ballot.votes[tokenAddr][user] != BallotResult.NOT_ACCEPTED;
    }

    function closeVoting()
        public
        override
    {
        require(block.timestamp > ballot.endTime, "Time is not over");
        ballot.status = BallotStatus.CLOSED;
    }

    function setGroupAdmin(
        address tokenAddr, 
        address newOwner
    )
        public
        override 
    {
        tokenAddr.call(abi.encodeWithSignature("transferOwnership(address)", newOwner));
    }

    function disableUserGroup(address tokenAddr) public {
        tokenAddr.call(abi.encodeWithSignature("removeFromProjects(address)", address(this)));

    }
}