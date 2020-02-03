pragma solidity 0.6.1;


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
		* @notice sets user group name
		* @param _self self
		* @param _name new group name
		* @return changed
		*/
	function setName(
			Group storage _self,
			string memory _name
	)
		internal
		returns (bool changed)
	{
				_self.name = _name;
			return keccak256(abi.encodePacked(_self.name)) == keccak256(abi.encodePacked(_name));
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
				_group.groupAddress != address(0)
			);
	}
}
