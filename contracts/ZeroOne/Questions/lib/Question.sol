// TODO:
// 1. starting formula
// 2. result formula
// 3. ? update question method selector
// 4. ? update question target address
// 5. ? when everything else is ready, possibly 
// we should add isContract() validation for 
// question target 

pragma solidity 0.6.1;


/**
 * @title Question
 * @dev Question data type implementation
 */
library QuestionType {
    uint private constant MIN_LENGTH = 10 minutes;
    uint private constant MAX_LENGTH = 1 weeks;
 
    struct Question {
        bool active;
        string name;
        string description;
        uint groupId;
        uint timeLimit;
        string[] paramNames;
        string[] paramTypes;
        address target;
        bytes4 methodSelector;
    }

    /**
     * @notice sets question status
     * @param _self self
     * @param _status new status
     * @return changed
     */
    function setActiveStatus(
        Question storage _self,
        bool _status
    )
        internal
        returns (bool changed)
    {
        _self.active = _status;
        return (_self.active == _status);
    }

    /**
     * @notice validates question
     * @param _question question
     * @return valid
     */
    function validate(
        Question memory _question
    )
        internal
        pure
        returns (bool valid)
    {
        return (
            _question.timeLimit > MIN_LENGTH
            && _question.timeLimit <= MAX_LENGTH
            && _question.paramNames.length == _question.paramTypes.length
            && _question.target != address(0)
        );
    }
}
