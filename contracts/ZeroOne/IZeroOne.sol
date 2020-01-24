pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

/**
 * @title IZeroOne
 * @dev implements ZeroOne interface
 */
interface IZeroOne {
    enum Result {
        UNDEFINED,
        ACCEPTED,
        DECLINED
    }

    struct MetaData {
        uint ballotId;
        uint questionId;
        uint startBlock;
        uint endBlock;
        Result result;
    }
}