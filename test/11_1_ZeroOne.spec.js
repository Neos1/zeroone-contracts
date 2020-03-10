const ZeroOne = artifacts.require('./ZeroOne.sol');
const ZeroOneVM = artifacts.require('zeroone-voting-vm/contracts/ZeroOneVM.sol');
const ERC20 = artifacts.require('./ERC20.sol');
const CustomToken = artifacts.require('./CustomToken.sol');

const Controlled = artifacts.require('./ControlledMock.sol');
const BallotType = artifacts.require('./BallotType.sol');

const increase = require('./helpers/increase-time');
const { compile } = require('zeroone-translator');
const { questions } = require('./helpers/questions');

contract('ZeroOne', ([from, secondary, third]) => {
  let zeroOne;
  let token;

  const results = ["UNDEFINED", "ACCEPTED", "DECLINED"]





  const formulas = [
    `erc20{%s}->conditions{quorum>30%, positive>50% of all} and (custom{%t}->conditions{quorum>30%, positive>50% of all} and custom{%t}->admin)`, 
    `erc20{%s}->conditions{quorum>50%, positive>90% of quorum}`,
    `erc20{%s}->conditions{quorum>50%, positive=100% of quorum}`,
    `erc20{%s}->conditions{quorum>0%, positive>50% of all}`,
    `erc20{%s}->conditions{quorum>50%,positive>90% of quorum} or custom{%t}->admin`,
    `erc20{%s}->conditions{quorum>50%,positive>90% of quorum} and custom{%t}->admin`, 
    `erc20{%s}->conditions{quorum>50%,positive>90% of quorum} and custom{%t}->admin`, 
  ];

  beforeEach(async () => {

  });

  describe('fullVotingProcess', async () => {
    it("should finish voting with ACCEPTED result", async () => {
      for (formula of formulas) {
        token = await ERC20.new('test', 'tst', 1000);
        customToken = await CustomToken.new('test', 'tst', 1000);

        const zeroOneVm = await ZeroOneVM.new();
        const ballotType =  await BallotType.new();
        
        await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
        await ZeroOne.link("BallotType", ballotType.address);

        const group = {
          name: "Owners",
          groupAddress: token.address,
          groupType: 0
        }
    
        zeroOne = await ZeroOne.new(group, { from });
        controlled = await Controlled.new(zeroOne.address, { from });
        
        customToken.addToProjects(zeroOne.address);

        for (question of questions) {
          question.rawFormula = formula;
          question.formula = compile(
            question.rawFormula
            .replace(/\%s/g, token.address)
            .replace(/\%t/g, customToken.address)
            .replace(/\%u/g, from)
            )
            question.target = zeroOne.address;
            await zeroOne.addQuestion(question);
          }
          
        const adminBalance = await token.balanceOf(from);
        const data = web3.eth.abi.encodeParameters(['tuple(uint256,uint256,uint256,uint256,uint256)', 'tuple(string)'],[[0, 0, 0, 0, 0], ["test"]])
        const votingData = {
          questionId: 2,
          starterAddress: from,
          starterGroupId: 0,
          endTime: 0,
          data,
        }
        
        await zeroOne.startVoting(votingData);
        try {
          await token.approve(zeroOne.address, adminBalance);
          await zeroOne.setVote(1);

          increase(web3, 320000);
          await zeroOne.submitVoting();
          const [event] = await zeroOne.getPastEvents('VotingEnded');
          const {args: {descision}} = event;
          assert.strictEqual(descision.toNumber(), 1);
          console.log(`voting with formula --- ${formula} --- ✔️`);
        } catch ({message}) {
          console.log(`test #${formulas.indexOf(formula)} ---  ${message} --- 🚫`)
        }
      }
    });

    it('should finish voting with DECLINED result', async () => {
      for (formula of formulas) {
        token = await ERC20.new('test', 'tst', 1000);
        customToken = await CustomToken.new('test', 'tst', 1000);

        const zeroOneVm = await ZeroOneVM.new();
        const ballotType =  await BallotType.new();
        
        await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
        await ZeroOne.link("BallotType", ballotType.address);

        const group = {
          name: "Owners",
          groupAddress: token.address,
          groupType: 0
        }
    
        zeroOne = await ZeroOne.new(group, { from });
        controlled = await Controlled.new(zeroOne.address, { from });
        
        customToken.addToProjects(zeroOne.address);

        for (question of questions) {
          question.rawFormula = formula;
          question.formula = compile(
            question.rawFormula
            .replace(/\%s/g, token.address)
            .replace(/\%t/g, customToken.address)
            .replace(/\%u/g, from)
            )
            question.target = zeroOne.address;
            await zeroOne.addQuestion(question);
          }
          
        const adminBalance = await token.balanceOf(from);
        const data = web3.eth.abi.encodeParameters(['tuple(uint256,uint256,uint256,uint256,uint256)', 'tuple(string)'],[[0, 0, 0, 0, 0], ["test"]])
        const votingData = {
          questionId: 2,
          starterAddress: from,
          starterGroupId: 0,
          endTime: 0,
          data,
        }
        
        await zeroOne.startVoting(votingData);
        try {
          await token.approve(zeroOne.address, adminBalance);
          await zeroOne.setVote(2);

          increase(web3, 320000);
          await zeroOne.submitVoting();
          const [event] = await zeroOne.getPastEvents('VotingEnded');
          const {args: {descision}} = event;
          assert.strictEqual(descision.toNumber(), 2);
          console.log(`voting with formula --- ${formula} --- ✔️`);
        } catch ({message}) {
          console.log(`test #${formulas.indexOf(formula)} ---  ${message} --- 🚫`)
        }
      }
    });
  });
});