pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "../ZeroOne/ZeroOne.sol";


/**
 * @title ZeroOneMock
 * @dev wrapper to test some ZeroOne methods
 */
contract ZeroOneMock is ZeroOne {

    constructor(address _owners) public {
        UserGroup.Group memory _group = UserGroup.Group({
            name: "Owners",
            groupAddress: _owners,
            groupType: UserGroup.Type.ERC20
        });
        addUserGroup(_group);
    }
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
