pragma solidity 0.6.1;

import "../lib/Meta.sol";


/**
 * @title MetaMock
 * @dev wrapper to test Meta library methods
 */
contract MetaMock {
    using Meta for bytes;

    /**
     * @notice wrapper for internal Meta addMetaData()
     * @param _data data to modify
     * @param _meta1 some test param to replace first part of data
     * @param _meta2 some test param to replace second part of data
     * @return data modified
     */
    function testMeta(
        bytes memory _data,
        uint _meta1,
        uint _meta2
    )
        public
        pure
        returns (bytes memory data)
    {
        data = _data.addMetaData(abi.encodePacked(_meta1, _meta2));
    }
}
