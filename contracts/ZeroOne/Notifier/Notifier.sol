pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../../lib/Selector.sol";


/**
 * @title Notifier
 * @dev implements address method call
 */
abstract contract Notifier {
    using Selector for bytes4;

    event Call(
        bytes4 selector,
        bytes data,
        bool result,
        bytes response
    );

    /**
     * @notice makes call to contract external method 
     * @param _target contract address to make call to
     * @param _method method selector
     * @param _data data to provide with call
     * @return result
     */
    function notify(
        address _target,
        bytes4 _method,
        bytes memory _data
    )
        internal
        virtual
        returns (bool result)
    {
        bytes memory response;
        (result, response) = _method.makeCall(
            _target,
            _data
        );
        emit Call(
            _method,
            _data,
            result,
            response
        );
    }
}