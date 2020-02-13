const Ballot = artifacts.require('Ballots.sol');
const Questions = artifacts.require('QuestionsWithGroups.sol');
const UserGroups = artifacts.require('UserGroups.sol');
const CustomToken = artifacts.require('CustomToken.sol');

const { getErrorMessage, getShortErrorMessage } = require('./helpers/get-error-message');

contract('Ballot', ([from, secondary]) => {
  let ballot;
  let questions;
  let usergroups;
  let customToken;

  const primaryInfo = {
    starterGroupId: 1,
    starterAddress: secondary,
    questionId: 0,
    data: '0x'
  }

  beforeEach( async () => {
    ballot = await Ballot.new({ from });
    questions = await Questions.new({ from });
    usergroups = await UserGroups.new({ from });
    customToken = await CustomToken.new('test', 'tst', 1000, { from });
  });

  describe('constructor()', () => {
    it('should be successfully created', async () => {
      ballot = await Ballot.new({ from });
      const amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 0)
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
        startTime, 
        starterGroupId, 
        starterAddress,
        questionId,
        status,
        result
      } = await ballot.getVoting(0);

      assert.strictEqual(starterGroupId.toNumber(), 1);
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

      const tx = await ballot.setVote(from, secondary, 1, 200)
      const {args : {
        user, group, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, secondary);
      assert.strictEqual(group, from)
      assert.strictEqual(descision.toNumber(), 1)
    })

    it('should successfully set Negative vote', async () => {
      await ballot.startVoting(primaryInfo);

      const tx = await ballot.setVote(from, secondary, 0, 200)
      const {args : {
        user, group, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, secondary);
      assert.strictEqual(group, from)
      assert.strictEqual(descision.toNumber(), 0)
    })

    it('should successfully remove vote', async () => {
      
    })

    it('should fail on remove vote of user, which not vote', async () => {
      
    })
  })

  describe('closeVoting()', () => {
    it('should successfully close voting', async () => {

    })

    it('should fail on close voting, when time is not over', async () => {
      
    });
  })

  describe('events', () => {})
});