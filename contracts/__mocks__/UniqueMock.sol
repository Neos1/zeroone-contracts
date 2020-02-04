pragma solidity 0.6.1;

import "../lib/UniqueNames.sol";


/**
 * @title UniqueMock
 * @dev wrapper to test UniqueNames library methods
 */
contract UniqueMock {
    using UniqueNames for UniqueNames.List;
    UniqueNames.List names;

    /**
     * @notice wrapper for internal UniqueName add()
     * @param name name for adding
     */
    function testAdd(
        string memory name
    )
        public
    {
        names.add(name);
    }

    /**
     * @notice wrapper for internal UniqueName isUnique()
     * @param name name for checking
     * @return unique 
     */
    function testIsUnique(
        string memory name
    )
        public
        view
        returns(bool unique)
    {
        return names.isUnique(name);
    }

}
