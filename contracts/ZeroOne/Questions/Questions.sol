pragma solidity 0.6.1;
pragma experimental ABIEncoderV2;

import "./lib/QuestionList.sol";
import "./lib/Question.sol";


/**
 * @title Questions
 * @dev stores questions
 */
contract Questions {
    using QuestionList for QuestionList.List;
    using QuestionType for QuestionType.Question;

    QuestionList.List questions;

    event QuestionAdded(
        uint id,
        string name,
        bytes4 methodSelector
    );

    /**
     * @notice reverts on non-existing question id
     * @param _id question id
     */
    modifier questionExists(
        uint _id
    ) {
        require(
            questions.checkId(_id),
            "Provided index is out of bounds"
        );
        _;
    }

    constructor() public {}

    /**
     * @notice gets question data
     * @param _id question id
     * @return question
     */
    function getQuestion(
        uint _id
    )
        public
        view
        questionExists(_id)
        returns (QuestionType.Question memory question)
    {
        return questions.list[_id];
    }

    /**
     * @notice gets questions amount
     * @return length
     */
    function getQuestionsAmount()
        public
        view
        returns (uint length)
    {
        return questions.list.length;
    }

    /**
     * @notice adds new question to list
     * @param _question question
     * @return id
     */
    function addQuestion(
        QuestionType.Question memory _question
    )
        virtual
        public
        returns (uint id)
    {
        id = questions.add(_question);
        emit QuestionAdded(
            id,
            _question.name,
            _question.methodSelector
        );
    }

    /**
     * @notice updates question activity status
     * @param _id id
     * @param _status active status
     * @return changed
     */
    function setActiveStatus(
        uint _id,
        bool _status
    )
        public
        questionExists(_id)
        returns (bool changed)
    {
        return questions.list[_id].setActiveStatus(_status);
    }
}
