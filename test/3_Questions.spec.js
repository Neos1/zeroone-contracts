const Questions = artifacts.require('./Questions.sol');

const { getErrorMessage } = require('./helpers/get-error-message');
const { compile, compileDescriptors } = require('zeroone-translator');
const {questions} = require('./helpers/questions');

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
            const contract = await Questions.new({ from: deployFrom });
            contract.addQuestion(question);
            const uploadedLength = await contract.getQuestionsAmount();
            assert.strictEqual(uploadedLength.toNumber(), 1);
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
            let error = false;
            try {
                const questionDuplicate = Object.create(question);
                await questions.addQuestion(question);
                await questions.addQuestion(questionDuplicate);
            } catch (e) {
                error = true;
            }
            
            assert.strictEqual(error, true);
        });

        it('should fail on uploading question with incorrect target', async () => {
            let error = false;
            try {
                const questionWithIncorrectAddress = Object.create(question);
                questionWithIncorrectAddress.target = '';
                await questions.addQuestion(questionWithIncorrectAddress);
            } catch (e) {
                error = true;
            }
            assert.strictEqual(error, true);
        });

        it('should fail on uploading question with lower time limit', async () => {
            try {
                questionWithIncorrectTime = Object.create(question);
                questionWithIncorrectTime.timeLimit = 1;
                await questions.addQuestion(questionWithIncorrectTime);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Invalid question'));
            }
        });

        it('should fail on uploading question with higher time limit', async () => {
            try {
                questionWithIncorrectTime = Object.create(question);
                questionWithIncorrectTime.timeLimit = 8 * 60 * 60 * 24;
                await questions.addQuestion(questionWithIncorrectTime);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Invalid question'));
            }
        });

        it('should fail on uploading question with incorrect params', async () => {
            try {
                const questionWithIncorrectParams = Object.create(question);
                questionWithIncorrectParams.paramNames = ['name'];
                questionWithIncorrectParams.paramTypes.push('address');
                await questions.addQuestion(questionWithIncorrectParams);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Invalid question'));
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
            let error = false;
            try {
                await questions.addQuestion(question);
                await questions.getQuestion(1)
            } catch (e) {
                error = true;
            }
            assert.strictEqual(error, true);
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

    describe('events', () => {
        it('should fire event on successful question adding', async () => {
            const tx = await questions.addQuestion(question);
            const log = tx.logs.find(element => element.event.match('QuestionAdded'));
            const {args: {id, name, methodSelector}} = log;
            assert.strictEqual(id.toNumber(), 0);
            assert.strictEqual(name, question.name);
            assert.strictEqual(methodSelector, question.methodSelector);
        })
    })
});
