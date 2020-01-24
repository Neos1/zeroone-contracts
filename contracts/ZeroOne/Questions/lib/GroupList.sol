pragma solidity 0.6.1;

import "./Group.sol";
import "./../../../lib/UniqueNames.sol";


/**
 * @title QuestionGroupList
 * @dev Question group list
 */
library GroupList {
    using GroupType for GroupType.Group;
    using UniqueNames for UniqueNames.List;

    struct List {
        GroupType.Group[] list;
        UniqueNames.List names;
    }

    /**
     * @notice adds new question group to list
     * @param _self self
     * @param _group group
     * @return id
     */
    function add(
        List storage _self,
        GroupType.Group memory _group
    )
        internal
        returns (uint id)
    {
        _self.names.add(_group.name);
        _self.list.push(_group);
        return _self.list.length - 1;
    }

    /**
     * @notice checks id existance
     * @param _self self
     * @param _id question group id
     * @return valid
     */
    function checkId(
        List storage _self,
        uint _id
    )
        internal
        pure
        returns (bool valid)
    {
        // TODO: implement this
        return true;
    }
}
