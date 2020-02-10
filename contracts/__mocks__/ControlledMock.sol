pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../Controlled/Controlled.sol";
import "../ZeroOne/IZeroOne.sol";

/**
 * @title ControlledMock
 * @dev wrapper to test Controlled contract
 */
contract ControlledMock is Controlled {
    uint public param1;
    string public param2;

    constructor(address _zeroOne) Controlled(_zeroOne) public {} 

    /**
     * @notice success test method
     * @param _meta meta data struct
     * @param _param1 some test param uint
     * @param _param2 some test param string
     */
    function testSuccess(
        IZeroOne.MetaData memory _meta,
        uint _param1,
        string memory _param2
    )
        public
        onlyZeroOne
    {
        require(
            handleZeroOneCall(_meta),
            "Can not be handled"
        );
        param1 = _param1;
        param2 = _param2;
    }

    /**
     * @notice fail test method
     * @param _meta meta data struct
     * @param _param1 some test param uint
     * @param _param2 some test param string
     */
    function testRevert(
        IZeroOne.MetaData memory _meta,
        uint _param1,
        string memory _param2
    )
        public
        onlyZeroOne
    {
        require(_param1 == 0);
        testSuccess(_meta, _param1, _param2);
    }

    /**
     * @notice fail test method with revert message
     * @param _meta meta data struct
     * @param _param1 some test param uint
     * @param _param2 some test param string
     */
    function testRevertMessage(
        IZeroOne.MetaData memory _meta,
        uint _param1,
        string memory _param2
    )
        public
        onlyZeroOne
    {
        require(
            _param1 == 0,
            "test"
        );
        testSuccess(_meta, _param1, _param2);
    }
} 
