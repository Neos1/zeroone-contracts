pragma solidity 0.6.1;


/**
 * @title Group
 * @dev Question group data type implementation
 */
library GroupType {
    struct Group {
        string name;
    }

    /**
     * @notice sets question group name
     * @param _self self
     * @param _name new group name
     * @return changed
     */
    function setName(
        Group storage _self,
        string memory _name
    )
        internal
        returns (bool changed)
    {
         _self.name = _name;
        return true;
    }
}
