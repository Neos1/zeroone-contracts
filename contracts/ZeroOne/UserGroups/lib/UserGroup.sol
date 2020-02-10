pragma solidity 0.6.1;

import "../IERC20.sol";

    /**
    * @title Group
    * @dev User group data type implementation
    */
library UserGroup {
    enum Type {ERC20, CUSTOM}

    struct Group {
        string name;
        address groupAddress;
        Type groupType;
    }

    /**
        @notice get user group token totalSupply
        @param _group user group
        @return totalSupply
    */
    function getTotalSupply(
        Group memory _group
    )
        internal
        view
        returns(uint256 totalSupply) 
    {
        IERC20 group = IERC20(_group.groupAddress);
        totalSupply = group.totalSupply();
    }

    /**
        @notice get user group Admin
        @param _group user group
        @return admin
    */
    function getAdmin(
        Group memory _group
    )
        internal
        view
        returns(address admin)
    {
        require(_group.groupType == Type.CUSTOM, "This is not custom token group");
        IERC20 group = IERC20(_group.groupAddress);
        admin = group.owner();
    }

    /**
    * @notice validates group
    * @param _group group
    * @return valid
    */
    function validate(
        Group memory _group
    )
        internal
        pure
        returns (bool valid)
    {
        return (
        // TODO: 
        // check that provided address is contract
        _group.groupAddress != address(0)
        );
    }
}
