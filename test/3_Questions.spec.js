const Questions = artifacts.require('./Questions.sol');
const getErrorMessage = require('./helpers/get-error-message');

contract('Questions', (accounts) => {
    let questions;
    const deployFrom = accounts[0];
    let question;

    beforeEach(async () => {
        questions = await Questions.new({ from: deployFrom });
        question = {
            active: true,
            name: 'name',
            description: 'description',
            groupId: 0,
            timeLimit: 1 * 60 * 60,
            paramNames: ['param1'],
            paramTypes: ['uint256'],
            target: accounts[0],
            methodSelector: '0x12121212'
        };
    });

    describe('constructor()', () => {
        it('should be successfully created', async () => {
            try {
                const contract = await Questions.new({ from: deployFrom });
                assert.notEqual(contract, null);
            } catch (e) {
                console.log(e.message);
            }
            
        });
    });
    
    describe('addQuestion()', () => {
        it('should successfully add new question', async () => {
            await questions.addQuestion(question);
            const uploaded = await questions.getQuestion(0);
            Object.keys(question).forEach((key) => {
                switch (typeof question[key]) {
                    case 'number':
                        assert.strictEqual(question[key], Number(uploaded[key]));
                        break;
                    case 'object':
                        assert.strictEqual(
                            JSON.stringify(question[key]), 
                            JSON.stringify(uploaded[key]),
                        );
                        break;
                    default:
                        assert.strictEqual(question[key], uploaded[key]);
                }
            });
        });

        it('shoud fail on uploading two same questions', async () => {
            try {
                const questionDuplicate = Object.create(question);
                await questions.addQuestion(question);
                await questions.addQuestion(questionDuplicate);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Name must be unique'))
            }
            
        });

        it('should fail on uploading question with incorrect target', async () => {
            try {
                const questionWithIncorrectAddress = Object.create(question);
                questionWithIncorrectAddress.target = '';
                await questions.addQuestion(questionWithIncorrectAddress);
            } catch (e) {
                assert.strictEqual(e.message, 'invalid address (arg="target", coderType="address", value="")')
            }

        });

        it('should fail on uploading question with incorrect time limit', async () => {
            try {
                questionWithIncorrectTime = Object.create(question);
                questionWithIncorrectTime.timeLimit = 1;
                await questions.addQuestion(questionWithIncorrectTime);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Invalid question'));
            }
        });

        it('should fail on uploading question with incorrect params', async () => {
            try {
                const questionWithIncorrectParams = Object.create(question);
                questionWithIncorrectParams.paramNames = '';
                await questions.addQuestion(questionWithIncorrectParams);
            } catch (e) {
                assert.strictEqual(e.message, 'expected array value (arg="paramNames", coderType="array", value="")');
            }
        });
    });

    describe('getQuestion()', () => {

        it('should get first question in list', async () => {
            await questions.addQuestion(question);
            const uploaded = await questions.getQuestion(0);
            assert.strictEqual(uploaded.name, 'name');
        });

        it('should fail on getting question with invalid id', async () => {
            try {
                await questions.addQuestion(question);
                await questions.getQuestion(1)
            } catch (e) {
                assert.strictEqual(e.message, 'Returned error: VM Exception while processing transaction: revert Provided index is out of bounds')
            }
        });
    });

    describe('setActiveStatus()', () => {

        it('should change active status of question', async () => {
            await questions.addQuestion(question);
            await questions.setActiveStatus(0, false);
            const uploaded = await questions.getQuestion(0);
            assert.strictEqual(uploaded.active, false);
        });

        it('should fail on changing status on incorrect value ', async () => {
            await questions.addQuestion(question);
            await questions.setActiveStatus(0, 'test');
            const uploaded = await questions.getQuestion(0);
            assert.strictEqual(uploaded.active, true);
        });
    });


    // : write tests for other cases
    // * 1. test timeLimit out of bounds
    // * 2. test params mismatch
    // * 3. test non-unique names
    // * 4. test getting question by invalid id
    // * 5. test address(0) target
    // * 6. test update activity status functionality
});
