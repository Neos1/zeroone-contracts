const Ballot = artifacts.require('BallotsMock.sol');
const ZeroOneVM = artifacts.require('ZeroOneVM.sol');
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
    zeroOneVM = await ZeroOneVM.new()
    await Ballot.link("ZeroOneVM", zeroOneVM.address);
    ballot = await Ballot.new({ from });
    customToken = await CustomToken.new('test', 'tst', 1000, { from });

    // await ballot.addQuestion(question)
  });

  describe('constructor()', () => {
    it('should be successfully created', async () => {
      ballot = await Ballot.new({ from });
      const amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 0);
    });
  });

  describe('addVoting()', () => {
    it('should add voting', async () => {
      
      // await ballot.setFormula("0x0041c8a92378323f33fc30b0a10e3fd771eb8f6dff010006010032320704000904000000");
      const tx = await ballot.testAddVoting(primaryInfo);
      const {args : {votingId, questionId}} = tx.logs.find(element => element.event.match('VotingStarted'));

      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(questionId.toNumber(), primaryInfo.questionId);

      const amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 1);
    });

    it('should fail on adding voting, while has active voting', async () => {
      let error = false;

      await ballot.testAddVoting(primaryInfo);
      try {
        await ballot.testAddVoting(primaryInfo);
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage('You have active voting'));
      }
      assert.strictEqual(error, true);
    });
  })

  describe('getVoting()', () => {
    it('should return information about voting',  async () => {
      await ballot.testAddVoting(primaryInfo);
      const { 
        endTime,
        starterGroupId, 
        starterAddress,
        questionId,
        status
      } = await ballot.getVoting(0);

      assert.strictEqual(starterGroupId.toNumber(), 0);
      assert.strictEqual(starterAddress, secondary);
      assert.strictEqual(questionId.toNumber(), 0);
      assert.strictEqual(status.toNumber(), 1);
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

      await ballot.testAddVoting(primaryInfo);

      amount = await ballot.getVotingsAmount();
      assert.strictEqual(amount.toNumber(), 1);
    });
  })

  describe('setVote()', () => {
    it('should successfully set Positive vote', async () => {
      await ballot.testAddVoting(primaryInfo);

      const tx = await ballot.setVote(1);
      const {args : {
        user, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, from);
      assert.strictEqual(descision.toNumber(), 1)
    })

    it('should successfully set Negative vote', async () => {
      await ballot.testAddVoting(primaryInfo);

      const tx = await ballot.setVote(2);
      const {args : {
        user, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, from);
      assert.strictEqual(descision.toNumber(), 2)
    })

    it('should successfully remove vote', async () => {
      await ballot.testAddVoting(primaryInfo);

      const tx = await ballot.setVote(1);
      const {args : {
        user, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, from);
      assert.strictEqual(descision.toNumber(), 1)
    })

    it('should fail on set new vote of user, which already voted', async () => {
      let error = false;
      await ballot.testAddVoting(primaryInfo);
      await ballot.setVote(1);
      try {
        error = true;
        await ballot.setVote(2);
      } catch ({message}) {
        assert.strictEqual(message, getErrorMessage('User already vote'));
      }
      assert.strictEqual(error, true)
    })
  })

  describe('closeVoting()', () => {
    it('should successfully close voting', async () => {
      await ballot.testAddVoting(primaryInfo);
      increaseTime(web3, 300000);
      const tx = await ballot.testCloseVoting();
      const {args : {votingId, descision}} = tx.logs.find(element => element.event.match('VotingEnded'));
      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(descision.toNumber(), 0);
    })

    it('should fail on close voting, when time is not over', async () => {
      let error = false;
      await ballot.testAddVoting(primaryInfo);
      try {
        await ballot.testCloseVoting();
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage('Time is not over yet'));
      }
      assert.strictEqual(error, true)
    });
  })

  describe('events', () => {
    it('should fire VotingStarted event', async () => {
      const tx = await ballot.testAddVoting(primaryInfo);
      const {args : {votingId, questionId}} = tx.logs.find(element => element.event.match('VotingStarted'));

      assert.strictEqual(votingId.toNumber(), 0);
      assert.strictEqual(questionId.toNumber(), primaryInfo.questionId);
    });

    it('should fire UserVote event', async () => {
      await ballot.testAddVoting(primaryInfo);

      const tx = await ballot.setVote(1);
      const {args : {
        user, descision
      }} = tx.logs.find(element => element.event.match('UserVote'));

      assert.strictEqual(user, from);
      assert.strictEqual(descision.toNumber(), 1)
    });
  })
});