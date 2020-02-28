const Ballot = artifacts.require('Ballots.sol');
const Questions = artifacts.require('QuestionsWithGroups.sol');
const UserGroups = artifacts.require('UserGroups.sol');
const CustomToken = artifacts.require('CustomToken.sol');

const { getErrorMessage, getShortErrorMessage } = require('./helpers/get-error-message');
const increaseTime = require('./helpers/increase-time');

contract('Ballot', ([from, secondary]) => {
  let ballot;

  const primaryInfo = {
    starterGroupId: 0,
    starterAddress: secondary,
    questionId: 0,
    data: '0x',
    endTime: 0,
  }

  beforeEach( async () => {
    question = {
      active: true,
      name: 'question name',
      description: 'description',
      groupId: 0,
      timeLimit: 10 * 60 * 60,
      paramNames: ['param1'],
      paramTypes: ['uint256'],
      target: from,
      methodSelector: '0x12121212'
    };
    group = {
        name: 'group name'
    };
    ballot = await Ballot.new({ from });
    customToken = await CustomToken.new('test', 'tst', 1000, { from });

    await ballot.addQuestion(question)
  });

  describe('constructor()', () => {
    it('should be successfully created', async () => {
      ballot = await Ballot.new({ from });
      const amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 0);
    });
  });

  describe('startVoting()', () => {
    it('should start voting', async () => {

      const tx = await ballot.startVoting(primaryInfo);
      const {args : {votingId, questionId}} = tx.logs.find(element => element.event.match('VotingStarted'));

      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(questionId.toNumber(), primaryInfo.questionId);

      const amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 1);
    });

    it('should fail on start voting, while has active voting', async () => {
      let error = false;

      await ballot.startVoting(primaryInfo);
      try {
        await ballot.startVoting(primaryInfo);
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage('You have active voting'));
      }
      assert.strictEqual(error, true);
    });
  })

  describe('getVoting()', () => {
    it('should return information about voting',  async () => {
      await ballot.startVoting(primaryInfo);
      const { 
        endTime,
        starterGroupId, 
        starterAddress,
        questionId,
        status,
        result
      } = await ballot.getVoting(0);

      assert.strictEqual(starterGroupId.toNumber(), 0);
      assert.strictEqual(starterAddress, secondary);
      assert.strictEqual(questionId.toNumber(), 0);
      assert.strictEqual(status.toNumber(), 1);
      assert.strictEqual(result.toNumber(), 0);
    });

    it('should fail on getting non-existing voting', async () => {
      let error = false;
      try {
        await ballot.getVoting(0);
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getShortErrorMessage('Provided index out of bounds'))
      }
      assert.strictEqual(error, true);
    });
  })

  describe('getVotingsAmount()', () => {
    it('should successfully return amount of votings', async () => {
      let amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 0);

      await ballot.startVoting(primaryInfo);

      amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 1);
    });
  })

  describe('setVote()', () => {
    it('should successfully set Positive vote', async () => {
      await ballot.startVoting(primaryInfo);

      const tx = await ballot.setVote(from, secondary, 1, 200);
      const {args : {
        user, group, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, secondary);
      assert.strictEqual(group, from);
      assert.strictEqual(descision.toNumber(), 1)
    })

    it('should successfully set Negative vote', async () => {
      await ballot.startVoting(primaryInfo);

      const tx = await ballot.setVote(from, secondary, 2, 200);
      const {args : {
        user, group, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, secondary);
      assert.strictEqual(group, from);
      assert.strictEqual(descision.toNumber(), 2)
    })

    it('should successfully remove vote', async () => {
      await ballot.startVoting(primaryInfo);

      const tx = await ballot.setVote(from, secondary, 0, 0);
      const {args : {
        user, group, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, secondary);
      assert.strictEqual(group, from);
      assert.strictEqual(descision.toNumber(), 0)
    })

    it('should fail on set new vote of user, which already voted', async () => {
      let error = false;
      await ballot.startVoting(primaryInfo);
      await ballot.setVote(from, secondary, 1, 1000);
      try {
        error = true;
        await ballot.setVote(from, secondary, 2, 0);
      } catch ({message}) {
        assert.strictEqual(message, getErrorMessage('User already vote'));
      }
      assert.strictEqual(error, true)
    })
  })

  describe('closeVoting()', () => {
    it('should successfully close voting', async () => {
      await ballot.startVoting(primaryInfo);
      increaseTime(web3, 300000);
      const tx = await ballot.closeVoting();
      const {args : {votingId, descision}} = tx.logs.find(element => element.event.match('VotingEnded'));
      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(descision.toNumber(), 0);
    })

    it('should fail on close voting, when time is not over', async () => {
      let error = false;
      await ballot.startVoting(primaryInfo);
      try {
        await ballot.closeVoting();
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage('Time is not over yet'));
      }
      assert.strictEqual(error, true)
    });
  })

  describe('events', () => {
    it('should fire VotingStarted event', async () => {
      const tx = await ballot.startVoting(primaryInfo);
      const {args : {votingId, questionId}} = tx.logs.find(element => element.event.match('VotingStarted'));

      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(questionId.toNumber(), primaryInfo.questionId);
    });

    it('should fire VotingEnded event', async () => {
      await ballot.startVoting(primaryInfo);
      increaseTime(web3, 300000);
      const tx = await ballot.closeVoting();
      const {args : {votingId, descision}} = tx.logs.find(element => element.event.match('VotingEnded'));
      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(descision.toNumber(), 0);
    });

    it('should fire UserVote event', async () => {
      await ballot.startVoting(primaryInfo);

      const tx = await ballot.setVote(from, secondary, 1, 200);
      const {args : {
        user, group, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, secondary);
      assert.strictEqual(group, from);
      assert.strictEqual(descision.toNumber(), 1)
    });
  })
});