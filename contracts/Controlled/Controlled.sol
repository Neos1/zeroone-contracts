pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/IZeroOne.sol";


/**
 * @title Controlled
 * @dev contract that user contracts should inherit
 * or take as base to corretcly handle ZeroOne calls 
 */
abstract contract Controlled {
    address zeroOne;

    event ZeroOneCall (
        IZeroOne.MetaData meta
    );

    /**
     * @notice for modified functions allows calls only from ZeroOne contracts
     */
    modifier onlyZeroOne {
        require(
            msg.sender == zeroOne,
            "Only zeroOne contract can call this function"
        );
        _;
    }

    /**
     * @notice sets zeroOne address
     * @param _zeroOne zeroOne contract address
     */
    constructor(
        address _zeroOne
    )
        public
    {
        require(
            _zeroOne != address(0),
            "Provided address could not be empty"
        );
        zeroOne = _zeroOne;
    }

    /**
     * @notice sets zeroOne address
     * @param _meta meta data received from ZerOne contract
     * @return result 
     */
    function handleZeroOneCall(
        IZeroOne.MetaData memory _meta
    )
        internal
        virtual
        returns (bool result)
    {
        emit ZeroOneCall(_meta);
        return true;
    }
}