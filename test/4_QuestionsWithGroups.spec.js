const QuestionsWithGroups = artifacts.require('./QuestionsWithGroups.sol');

const { getErrorMessage } = require('./helpers/get-error-message');

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

    describe('getQuestionGroupsAmount()', () => {
        it('should successfully check amount of groups', async () => {
            const group  = { name: 'something' };
            await questionsWithGroups.addQuestionGroup(group);
            const countOfUploaded = await questionsWithGroups.getQuestionGroupsAmount();
            assert.equal(countOfUploaded.toNumber(), 2);
        });
       
    });

    describe('getQuestionGroup()', () => {
        it('should successfully get group "system"', async () => {
            const group = await questionsWithGroups.getQuestionGroup(0);
            assert.equal(group.name, 'system');
        });

        it('should fail on getting group out of bounds', async () => {
            let error = false;
            try {
                await questionsWithGroups.getQuestionGroup(25);
            } catch (e) {
                error = true;
            }
            assert.strictEqual(error, true)
        });
    });

    describe('addQuestionGroup()', () => {
        it('should successfully add group', async () => {
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

        it('should upload question and group with same name', async () => {
            const testGroup = Object.create(group);
            testGroup.name = 'question name'
            await questionsWithGroups.addQuestionGroup(testGroup);
            await questionsWithGroups.addQuestion(question);
            const uploadedQuestion = await questionsWithGroups.getQuestion(0);
            const uploadedGroup = await questionsWithGroups.getQuestionGroup(1);
            assert.strictEqual(uploadedQuestion.name, uploadedGroup.name)
        })
    });

    describe('setQuestionGroupName()', () => {
        it('should successfully change group name', async () => {
            name = 'test'
            await questionsWithGroups.addQuestionGroup(group);
            await questionsWithGroups.setQuestionGroupName(1, name);
            const uploadedGroup = await questionsWithGroups.getQuestionGroup(1);
            assert.strictEqual(uploadedGroup.name, name);
        });

        it('should fail on change name of non-existing group', async ()=> {
            try {
                name = 'test'
                await questionsWithGroups.setQuestionGroupName(12, name);
            } catch(e) {
                assert.strictEqual(e.message, getErrorMessage('Provided index is out of bounds'));
            }
        });
    });

    describe('events', () => {
        it('should fire event on successful adding new group of questions', async () => {
            const tx = await questionsWithGroups.addQuestionGroup(group);
            const log = tx.logs.find(element => element.event.match('QuestionGroupAdded'));
            const {args: {name}} = log;
            assert.strictEqual(name, group.name);
        })
    })
    // after user groups, owner functionality are implemented
    // 4. test question upload from owners, non-owners, etc. 
});
