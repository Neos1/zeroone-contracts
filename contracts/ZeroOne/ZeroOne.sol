pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./IZeroOne.sol";
import "./Notifier/Notifier.sol";
import "../lib/Meta.sol";


/**
 * @title ZeroOne
 * @dev main ZeroOne contract
 */
contract ZeroOne is Notifier, IZeroOne {
    using Meta for bytes;

    /**
     * @notice for modified functions allows only self external call
     */
    modifier onlySelf {
        require(
            msg.sender == address(this),
            "Only self call is possible"
        );
        _;
    }

    /**
     * @notice makes call to contract external method
     * with modified data (meta added)
     * @param _target contract address to make call to
     * @param _method method selector
     * @param _data data to provide with call
     * @param _metaData meta to update data
     * @return result
     */
    function makeCall(
        address _target,
        bytes4 _method,
        bytes memory _data,
        MetaData memory _metaData
    )
        internal
        returns (bool result)
    {
        return notify(
            _target,
            _method,
            _data.addMetaData(abi.encode(_metaData))
        );
    }
}
