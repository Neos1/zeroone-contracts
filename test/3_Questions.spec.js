const Questions = artifacts.require('./Questions.sol');

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
            // TODO: implement creation test
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
    });

    // TODO: write tests for other cases
    // 1. test timeLimit out of bounds
    // 2. test params mismatch
    // 3. test non-unique names
    // 4. test getting question by invalid id
    // 5. test address(0) target
    // 6. test update activity status functionality
});
