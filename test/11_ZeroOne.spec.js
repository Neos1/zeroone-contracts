const Controlled = artifacts.require('./ControlledMock.sol');
const ERC20 = artifacts.require('./ERC20.sol');
const ZeroOne = artifacts.require('./ZeroOne.sol');
const BallotType = artifacts.require('./BallotType.sol');
const ZeroOneVM = artifacts.require('zeroone-voting-vm/contracts/ZeroOneVM.sol');

const increase = require('./helpers/increase-time');
const { compile, compileDescriptors } = require('zeroone-translator');
const { questions } = require('./helpers/questions');

contract('ZeroOne', ([from, secondary]) => {
  let zeroOne;
  let token;

  beforeEach(async () => {
    token = await ERC20.new('test', 'tst', 1000);

    const group = {
      name: "Owners",
      groupAddress: token.address,
      groupType: 0
    }

    const zeroOneVm = await ZeroOneVM.new();
    const ballotType =  await BallotType.new();

    await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
    await ZeroOne.link("BallotType", ballotType.address);

    zeroOne = await ZeroOne.new(group, { from });
    controlled = await Controlled.new(zeroOne.address, { from });
  });

  describe('addQuestion()', () => {
    it('should add system questions', async () => {
        for (let i = 0; i < questions.length; i++) {
            questions[i].formula = compile(questions[i].rawFormula.replace('%s', token.address))
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
              questions[i].formula = compile(questions[i].rawFormula.replace('%s', token.address))
              questions[i].target = zeroOne.address;
              questions[i].active = true;
              await zeroOne.addQuestion(questions[i]);
          }
          const data = web3.eth.abi.encodeParameters(['tuple(uint256,uint256,uint256,uint256,uint256)', 'tuple(string)'], [[0, 0, 0, 0, 0], ["test"]])
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
          await zeroOne.setVote(1);
          increase(web3, 320000);
          const {positive, negative, totalSupply} = await zeroOne.getGroupVotes(0, token.address);
          console.log(positive.toNumber(), negative.toNumber(), totalSupply.toNumber());
      });
  });
});