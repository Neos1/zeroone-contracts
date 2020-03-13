pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/GroupList.sol";
import "./lib/Group.sol";
import "./Questions.sol";


contract QuestionsWithGroups is Questions {
    using GroupList for GroupList.List;
    using GroupType for GroupType.Group;

    GroupList.List questionGroups;

    event QuestionGroupAdded(
        uint id,
        string name
    );

    /**
     * @notice reverts on non-existing question group id
     * @param _id question group id
     */
    modifier questionGroupExists(
        uint _id
    ) {
        require(
            questionGroups.checkId(_id),
            "Provided index is out of bounds"
        );
        _;
    }

    constructor() public {
        GroupType.Group memory systemGroup = GroupType.Group({
            name: "system"
        });
        questionGroups.add(systemGroup);
    }

    /**
     * @notice gets question group data
     * @param _id question group id
     * @return questionGroup
     */
    function getQuestionGroup(
        uint _id
    )
        public
        view
        questionGroupExists(_id)
        returns (GroupType.Group memory questionGroup)
    {
        return questionGroups.list[_id];
    }

    /**
     * @notice gets question groups amount
     * @return length
     */
    function getQuestionGroupsAmount()
        public
        view
        returns (uint length)
    {
        return questionGroups.list.length;
    }

    /**
     * @notice updates question group name
     * @param _id id
     * @param _name new question group name
     * @return changed
     */
    function setQuestionGroupName(
        uint _id,
        string memory _name
    )
        public
        questionGroupExists(_id)
        returns (bool changed)
    {
        return questionGroups.list[_id].setName(_name);
    }

    /**
     * @notice adds new question group to list
     * @param _questionGroup question group
     * @return id
     */
    function addQuestionGroup(
        GroupType.Group memory _questionGroup
    )
        virtual
        public
        returns (uint id)
    {
        id = questionGroups.add(_questionGroup);
        emit QuestionGroupAdded(
            id,
            _questionGroup.name
        );
    }

    /**
     * @notice adds new question to list
     * @param _question question
     * @return id
     */
    function addQuestion(
        QuestionType.Question memory _question
    )
        public
        override
        questionGroupExists(_question.groupId)
        returns (uint id)
    {
        // TODO:
        // 1. validate active property if group equals system
        // 2. validate group id
        // 3. validate system group with msg.sender (owner)
        id = questions.add(_question);
        emit QuestionAdded(
            id,
            _question.name,
            _question.methodSelector
        );
    }
}
