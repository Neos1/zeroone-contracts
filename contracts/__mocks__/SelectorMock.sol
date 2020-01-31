pragma solidity 0.6.1;

import "../lib/Selector.sol";


/**
 * @title SelectorMock
 * @dev wrapper to test Selector library methods
 */
contract SelectorMock {
    using Selector for bytes4;

    /**
     * @notice wrapper for internal Selector addData()
     * @param _selector method selector
     * @param _data data to add to selector
     * @return data
     */
    function testSelector(
        bytes4 _selector,
        bytes memory _data
    )
        public
        pure
        returns (bytes memory data)
    {
        data = _selector.addData(_data);
    }

    function testMakeCall(
        bytes4 _selector,
        address _target,
        bytes memory _data
    )
        public
        returns (bool result, bytes memory response)
    {   
        (result, response) = _target.call(this.testSelector(_selector, _data));
    }
}
