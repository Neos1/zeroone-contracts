pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/UserGroupsList.sol";
import "./lib/UserGroup.sol";

/**
 * @title UserGroups
 * @dev stores user groups
 */
contract UserGroups {
    using UserGroupsList for UserGroupsList.List;
    using UserGroup for UserGroup.Group;

    UserGroupsList.List groups;

    event UserGroupAdded(
        uint id,
        string name,
        address groupAddress
    );

    /**
     * @notice reverts on non-existing group id
     * @param _id group id
     */
    modifier groupExists(
        uint _id
    ) {
        require(
        groups.checkId(_id),
        "Provided index is out of bounds"
        );
        _;
    }

    constructor() public {}

    /**
     * @notice get group data
     * @param _id group id
     * @return group
     */
    function getUserGroup(
        uint _id
    )
        public
        view
        groupExists(_id)
        returns (UserGroup.Group memory group)
    {
        return groups.list[_id];
    }

    /**
     * @notice gets groups amount
     * @return length
     */
    function getUserGroupsAmount()
        public
        view
        returns (uint length)
    {
        return groups.list.length;
    }

    /**
     * @notice adds new group to list
     * @param _group group
     * @return id
     */
    function addUserGroup(
        UserGroup.Group memory _group
    )
        public
        returns (uint id)
    {
        id = groups.add(_group);
        emit UserGroupAdded(
        id,
        _group.name,
        _group.groupAddress
        );
    }
}
