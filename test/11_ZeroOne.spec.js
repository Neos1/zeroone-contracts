const ZeroOne = artifacts.require('./ZeroOne.sol');
const Controlled = artifacts.require('./ControlledMock.sol');
const ERC20 = artifacts.require('./ERC20.sol');

const {questions} = require('./helpers/questions');
const increase = require('./helpers/increase-time');

contract('ZeroOne', ([from, secondary]) => {
  let zeroOne;
  let token;

  beforeEach(async () => {
    token = await ERC20.new('test', 'tst', 1000);
    zeroOne = await ZeroOne.new(token.address, { from });
    controlled = await Controlled.new(zeroOne.address, { from });
  });

  describe('addQuestion()', () => {
    it('should add system questions', async () => {
        for (let i = 0; i < questions.length; i++) {
            questions[i].target = zeroOne.address;
            questions[i].active = true;
            await zeroOne.addQuestion(questions[i]);
        }
        const amount = await zeroOne.getQuestionsAmount()
        assert.strictEqual(amount.toNumber(), 4);
    });
  });

  describe('fullVotingProcess', async () => {
      it('should add question group', async () => {
          for (let i = 0; i < questions.length; i++) {
              questions[i].target = zeroOne.address;
              questions[i].active = true;
              await zeroOne.addQuestion(questions[i]);
          }
          const data = web3.eth.abi.encodeParameters(['tuple(uint256,uint256,uint256,uint256,uint256)', 'string'], [[0, 0, 0, 0, 0], "test"])
          const votingData = {
              questionId: 2,
              starterAddress: from,
              starterGroupId: 0,
              endTime: 0,
              data,
          }
          await zeroOne.startVoting(votingData);
          const userBalance = await token.balanceOf(from);
          await token.approve(zeroOne.address, userBalance);
          await zeroOne.setVote(token.address, from, 1);
          increase(web3, 320000);
          const tx = await zeroOne.closeVoting();
          const log = tx.logs.find(element => element.event.match('Call'));
          const group  = await zeroOne.getQuestionGroup(1);
          // console.log(group);
          // assert.strictEqual(group.name, 'test');

      });
      it('should add question', async () => {
        for (let i = 0; i < questions.length; i++) {
            questions[i].target = zeroOne.address;
            questions[i].active = true;
            await zeroOne.addQuestion(questions[i]);
        }
        const data = web3.eth.abi.encodeParameters(
          ['tuple(uint256,uint256,uint256,uint256,uint256)', 
           'tuple(bool, string, string, uint256, uint256, string[], string[], address, bytes4)'], 
          [
            [0, 0, 0, 0, 0], 
            [true, "test question", "some text", 0, 360000, ['test'], ['string'], secondary, "0x00000000"]
          ]
        )
        const votingData = {
            questionId: 0,
            starterAddress: from,
            starterGroupId: 0,
            endTime: 0,
            data,
        }
        let amount  = await zeroOne.getQuestionsAmount();
        try {
          console.log(`amount = ${amount.toNumber()}`)
          await zeroOne.startVoting(votingData);
          const userBalance = await token.balanceOf(from);
          await token.approve(zeroOne.address, userBalance);
          await zeroOne.setVote(token.address, from, 1);
          increase(web3, 320000);
          const tx = await zeroOne.closeVoting();
          const {args:{data}} = tx.logs.find(element => element.event.match('Call'));
          console.log(web3.eth.abi.decodeParameters(['tuple(bool, string, string, uint256, uint256, string[], string[], address, bytes4)'], data));
          amount  = await zeroOne.getQuestionsAmount();
          //assert.strictEqual(amount.toNumber(), 5);
        } catch({message}) {
          console.log(message);
        }
    });
  });
});