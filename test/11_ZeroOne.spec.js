const ZeroOne = artifacts.require('./ZeroOne.sol');
const ZeroOneVM = artifacts.require('zeroone-voting-vm/contracts/ZeroOneVM.sol');
const ERC20 = artifacts.require('./ERC20.sol');
const CustomToken = artifacts.require('./CustomToken.sol');

const Controlled = artifacts.require('./ControlledMock.sol');
const BallotType = artifacts.require('./BallotType.sol');

const increase = require('./helpers/increase-time');
const { compile } = require('zeroone-translator');
const { questions } = require('./helpers/questions');

contract('ZeroOne', ([from, secondary]) => {
  let zeroOne;
  let token;


  const formulas = [
    `erc20{${address}}->conditions{quorum>50%, positive=100% of quorum}`,
    `erc20{${address}}->conditions{quorum>50%, positive>90% of quorum}`,
    `erc20{${addresses[1]}}->conditions{quorum>50%,positive>90% of quorum} or custom{${address}}->admin`,
    `erc20{${addresses[1]}}->conditions{quorum>50%,positive>90% of quorum} and custom{${address}}->admin`,
    `erc20{${address}}->conditions{quorum>30%, positive>50% of all}
      or (
          custom{${addresses[0]}}->conditions{quorum>30%, positive>50% of all}
          and custom{${addresses[0]}}->admin
      )`
  ];

  beforeEach(async () => {
    token = await ERC20.new('test', 'tst', 1000);
    customToken = await CustomToken.new('test', 'tst', 1000)

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
          await zeroOne.submitVoting();

          const questionGroupsAmount = await zeroOne.getQuestionGroupsAmount();
          assert.strictEqual(questionGroupsAmount.toNumber(), 2);

          const questionGroup = await zeroOne.getQuestionGroup(1);
          assert.strictEqual(questionGroup.name, 'test');
      });
  });
});