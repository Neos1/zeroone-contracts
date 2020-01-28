const QuestionsWithGroups = artifacts.require('./QuestionsWithGroups.sol');
const getErrorMessage = require('./helpers/get-error-message');

contract('QuestionsWithGroups', (accounts) => {
    let questionsWithGroups;
    const deployFrom = accounts[0];
    let question;
    let group;

    beforeEach(async () => {
        questionsWithGroups = await QuestionsWithGroups.new({ from: deployFrom });
        question = {
            active: true,
            name: 'question name',
            description: 'description',
            groupId: 0,
            timeLimit: 1 * 60 * 60,
            paramNames: ['param1'],
            paramTypes: ['uint256'],
            target: accounts[0],
            methodSelector: '0x12121212'
        };
        group = {
            name: 'group name'
        }
    });

    describe('constructor()', () => {
        it('should be successfully created', async () => {
            const groupsLength = await questionsWithGroups.getQuestionGroupsAmount();
            const group = await questionsWithGroups.getQuestionGroup(0);
            assert.strictEqual(groupsLength.toNumber(), 1);
            assert.strictEqual(group.name, 'system');
        });
    });

    describe('addQuestion()', () => {
        it('should add question', async () => {
            await questionsWithGroups.addQuestion(question);
            const uploaded = await questionsWithGroups.getQuestion(0);
            assert.strictEqual(uploaded.name, 'question name');
        });

        it('shoud fail on uploading two same questions', async () => {
            try {
                const questionDuplicate = Object.create(question);
                await questionsWithGroups.addQuestion(question);
                await questionsWithGroups.addQuestion(questionDuplicate);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Name must be unique'))
            } 
        });
    });

    describe('getQuestionGroupsAmount()', () => {
        it('should successful check amount of groups', async () => {
            const group  = { name: 'something' };
            await questionsWithGroups.addQuestionGroup(group);
            const countOfUploaded = await questionsWithGroups.getQuestionGroupsAmount();
            assert.equal(countOfUploaded, web3.utils.toBN(2));
        });
       
    });

    describe('getQuestionGroup()', () => {
        it('should successful get group "system"', async () => {
            const group = await questionsWithGroups.getQuestionGroup(0);
            assert.equal(group.name, 'system');
        });

        it('should fail on getting group out of bounds', async () => {
            try {
                await questionsWithGroups.getQuestionGroup(25);
            } catch (e) {
                assert.equal(e.message, 'Returned error: VM Exception while processing transaction: revert Provided index is out of bounds');
            }
        });
    });

    describe('addQuestionGroup()', () => {
        it('should successful add group', async () => {
            await questionsWithGroups.addQuestionGroup(group);
            const uploadedGroup = await questionsWithGroups.getQuestionGroup(1);
            assert.strictEqual(uploadedGroup.name , 'group name');
        });

        it('should fail on non-unique name', async () => {
            try {
                await questionsWithGroups.addQuestionGroup(group);
                await questionsWithGroups.addQuestionGroup(group);
            } catch (e) {
                assert.strictEqual(e.message, getErrorMessage('Name must be unique'))
            }
        });
    });

    describe('setQuestionGroupName()', () => {
        it('should successful change group name', async () => {
            name = 'test'
            await questionsWithGroups.addQuestionGroup(group);
            await questionsWithGroups.setQuestionGroupName(1, name);
            const uploadedGroup = await questionsWithGroups.getQuestionGroup(1);
            assert.strictEqual(uploadedGroup.name, name);
        });

        it('should fail on change name of non-unique group', async ()=> {
            try {
                name = 'test'
                await questionsWithGroups.setQuestionGroupName(12, name);
            } catch(e) {
                assert.strictEqual(e.message, getErrorMessage('Provided index is out of bounds'));
            }
        })
    });

    


    // TODO: write tests for other cases
    // * 1. test non-unique names
    // 2. test upload question and group with same names 
    // 3. test group name update
    // after user groups, owner functionality are implemented
    // 4. test question upload from owners, non-owners, etc. 
});
