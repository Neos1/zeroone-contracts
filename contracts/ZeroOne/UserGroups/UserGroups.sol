pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/GroupsList.sol";
import "./lib/Group.sol";

/**
 * @title groups
 * @dev stores groups
 */
contract UserGroups {
    using UserGroupsList for UserGroupsList.List;
    using GroupType for GroupType.Group;

    UserGroupsList.List groups;

    event GroupAdded(
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
     * @notice gets group data
     * @param _id group id
     * @return group
     */
    function getGroup(
        uint _id
    )
        public
        view
        groupExists(_id)
        returns (GroupType.Group memory group)
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
    function addGroup(
        GroupType.Group memory _group
    )
        public
        virtual
        returns (uint id)
    {
        id = groups.add(_group);
        emit GroupAdded(
            id,
            _group.name,
            _group.groupAddress
        );
    }
}
