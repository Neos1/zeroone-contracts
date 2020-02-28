pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "zeroone-voting-vm/contracts/ZeroOneVM.sol";

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
        VM.Vote result;
    }
}
