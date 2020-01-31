pragma solidity 0.6.1;

import "./Group.sol";
import "./../../../lib/UniqueNames.sol";

/**
	* @title GroupsList
	* @dev UserGroups list
 */

library UserGroupsList {
	using GroupType for GroupType.Group;
	using UniqueNames for UniqueNames.List;

	struct List {
		GroupType.Group[] list;
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
		GroupType.Group memory _group
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