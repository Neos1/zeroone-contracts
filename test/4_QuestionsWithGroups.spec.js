const QuestionsWithGroups = artifacts.require('./QuestionsWithGroups.sol');

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

    // TODO: write tests for other cases
    // 1. test non-unique names
    // 2. test upload question and group with same names 
    // 3. test group name update
    // after user groups, owner functionality are implemented
    // 4. test question upload from owners, non-owners, etc. 
});
