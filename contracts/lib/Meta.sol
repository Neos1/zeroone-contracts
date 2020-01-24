pragma solidity 0.6.1;

import "../__vendor__/BytesLib.sol";


/**
 * @title Meta
 * @dev library to replace first part of data in calldata 
 * with provided
 */
library Meta {
    using BytesLib for bytes;

    /**
     * @notice replaces part of bytes from start with provided bytes
     * @param _data calldata to be modified
     * @param _meta new data to replace old one from start 
     * @return data midified calldata
     */
    function addMetaData(
        bytes memory _data,
        bytes memory _meta
    )
        internal
        pure
        returns (bytes memory data) 
    {
        uint start = _meta.length;
        uint length = _data.length - start;
        data = _meta.concat(_data.slice(start, length));
    }
}