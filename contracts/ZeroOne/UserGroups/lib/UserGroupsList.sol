pragma solidity 0.6.1;

import "./UserGroup.sol";
import "./../../../lib/UniqueNames.sol";

/**
	* @title GroupsList
	* @dev UserGroups list
 */

library UserGroupsList {
	using UserGroup for UserGroup.Group;
	using UniqueNames for UniqueNames.List;

	struct List {
		UserGroup.Group[] list;
		UniqueNames.List names;
	}

	/**
		* @notice adds new group to list
		* @param _self self
		* @param _group group
		* @return id
	*/
	function add(
		List storage _self,
		UserGroup.Group memory _group
	)
		internal
		returns (uint id)
	{
		require(
			_group.validate(),
			"Invalid group"
		);
		_self.names.add(_group.name);
		_self.list.push(_group);
		return _self.list.length - 1;
	}

	/**
		* @notice checks id existance
		* @param _self self
		* @param _id group id
		* @return valid
		*/
	function checkId(
			List storage _self,
			uint _id
	)
			internal
			view
			returns (bool valid)
	{
			return _self.list.length > _id;
	}
  
}