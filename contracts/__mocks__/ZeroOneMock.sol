pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/ZeroOne.sol";


/**
 * @title ZeroOneMock
 * @dev wrapper to test some ZeroOne methods
 */
contract ZeroOneMock is ZeroOne {
    /**
     * @notice wrapper for internal makeCall method
     * @param _target contract address to make call to
     * @param _method method selector
     * @param _data data to provide with call
     * @param _metaData meta to update data
     * @return result
     */
    function testMakeCall(
        address _target,
        bytes4 _method,
        bytes memory _data,
        MetaData memory _metaData
    )
        public
        returns (bool result)
    {
        return makeCall(
            _target,
            _method,
            _data,
            _metaData
        );
    }
}
