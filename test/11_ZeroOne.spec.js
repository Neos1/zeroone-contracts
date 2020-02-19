const ZeroOne = artifacts.require('./ZeroOne.sol');
const Controlled = artifacts.require('./ControlledMock.sol');
const ERC20 = artifacts.require('./ERC20.sol');

const {questions} = require('./helpers/questions');
const increase = require('./helpers/increase-time');

contract('ZeroOne', ([from, secondary]) => {
  let zeroOne;
  let token;

  let func = {
    "inputs": [
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "ballotId",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "questionId",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "startBlock",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "endBlock",
            "type": "uint256"
          },
          {
            "internalType": "enum IZeroOne.Result",
            "name": "result",
            "type": "uint8"
          }
        ],
        "internalType": "struct IZeroOne.MetaData",
        "name": "_meta",
        "type": "tuple"
      },
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  };

  beforeEach(async () => {
    token = await ERC20.new('test', 'tst', 1000);
    zeroOne = await ZeroOne.new(token.address, { from });
    controlled = await Controlled.new(zeroOne.address, { from });
    console.log(web3.eth.abi.encodeFunctionSignature(func));
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
          await zeroOne.setVote(token.address, from, 1);
          increase(web3, 320000);
          await zeroOne.closeVoting();
          const group  = await zeroOne.getQuestionGroup(1);
          assert.strictEqual(group.name, 'test');

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
        console.log(`amount = ${amount.toNumber()}`)

        await zeroOne.startVoting(votingData);
        const userBalance = await token.balanceOf(from);

        await token.approve(zeroOne.address, userBalance);
        await zeroOne.setVote(token.address, from, 1);

        const balance = await token.balanceOf(zeroOne.address);
        increase(web3, 320000);

        await zeroOne.closeVoting();
        amount  = await zeroOne.getQuestionsAmount();
        assert.strictEqual(amount.toNumber(), 5);
    });
  });
});