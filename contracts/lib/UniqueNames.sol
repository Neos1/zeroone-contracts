pragma solidity 0.6.1;


library UniqueNames {
    struct List {
        mapping (string => bool) names;
    }

    /**
     * @notice adds new name to list
     * @param _self self
     * @param _name name
     */
    function add(
        List storage _self,
        string memory _name
    )
        internal
    {
        require(
            isUnique(_self, _name),
            "Name must be unique"
        );
        _self.names[_name] = true;
    }

    /**
     * @notice checks if provided name is uniq
     * @param _self self
     * @param _name name
     */
    function isUnique(
        List storage _self,
        string memory _name
    )
        internal
        view
        returns (bool unique)
    {
        return !_self.names[_name];
    }
}
