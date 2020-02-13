pragma solidity 0.6.1;

import "../__vendor__/BytesLib.sol";


/**
 * @title Selector
 * @dev library to merge selector and data to calldata to use
 * with *address*.call(*calldata*) or *selector*.call(*address*, *data*)
 */
library Selector {
    using BytesLib for bytes;

    /**
     * @notice joins selector with data 
     * @param _selector method selector
     * @param _data data to call selector with
     * @return data calldata
     */
    function addData(
        bytes4 _selector,
        bytes memory _data
    )
        internal
        pure
        returns (bytes memory data)
    {
        data = abi.encodePacked(_selector).concat(_data);
    }

    /**
     * @notice calls selector with provided data on provided address
     * @param _selector method selector
     * @param _target contract address
     * @param _data data to call selector with
     * @return result (success | fail)
     * @return response (ex. revert message)
     */
    function makeCall(
        bytes4 _selector,
        address _target,
        bytes memory _data
    )
        internal
        returns (bool result, bytes memory response)
    {
        (result, response) = _target.call(addData(_selector, _data));
    }
}
