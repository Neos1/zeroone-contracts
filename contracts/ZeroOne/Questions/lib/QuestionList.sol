pragma solidity 0.6.1;

import "./Question.sol";
import "./../../../lib/UniqueNames.sol";


/**
 * @title QuestionList
 * @dev Question list
 */
library QuestionList {
    using QuestionType for QuestionType.Question;
    using UniqueNames for UniqueNames.List;

    struct List {
        QuestionType.Question[] list;
        UniqueNames.List names;
    }

    /**
     * @notice adds new question to list
     * @param _self self
     * @param _question question
     * @return id
     */
    function add(
        List storage _self,
        QuestionType.Question memory _question
    )
        internal
        returns (uint id)
    {
        require(
            _question.validate(),
            "Invalid question"
        );
        _self.names.add(_question.name);
        _self.list.push(_question);
        return _self.list.length - 1;
    }

    /**
     * @notice checks id existance
     * @param _self self
     * @param _id question id
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
        return (_self.list.length - 1) >= _id;
    }
}
