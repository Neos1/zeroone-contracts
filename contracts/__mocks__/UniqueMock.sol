pragma solidity 0.6.1;

import "../lib/UniqueNames.sol";


/**
 * @title SelectorMock
 * @dev wrapper to test Selector library methods
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
}
