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
  let customToken;

  const results = ["UNDEFINED", "ACCEPTED", "DECLINED"]



  const uploadQuestions = async (formula, zeroOne) => {
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
  }

  const startVoting = async (zeroOne, token) => {
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
    await token.approve(zeroOne.address, adminBalance);
  }

  const makeTransfers = async (token, transfers) => {

  }

  const makeVotes = async (zeroOne, votes) => {

  }

  const getDescision = async (zeroOne) => {
    const [event] = await zeroOne.getPastEvents('VotingEnded');
    const {args: {descision}} = event;
    return descision.toNumber();
  }

  const Voter = async (formula, data) => {
    token = await ERC20.new('test', 'tst', 1000);
    customToken = await CustomToken.new('test', 'tst', 1000);

    const group = {
      name: "Owners",
      groupAddress: token.address,
      groupType: 0
    }

    const zeroOneVm = await ZeroOneVM.new();
    const ballotType =  await BallotType.new();
    
    await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
    // await ZeroOne.link("BallotType", ballotType.address);


    zeroOne = await ZeroOne.new(group, { from });
    controlled = await Controlled.new(zeroOne.address, { from });
    
    customToken.addToProjects(zeroOne.address);

    await uploadQuestions(formula, zeroOne);

    await startVoting(zeroOne, token);

    await zeroOne.setVote(1);

    await makeVotes(zeroOne, votes);

    increase(web3, 320000);

    await zeroOne.submitVoting();

    return(await getDescision(zeroOne));
  }

  describe('findLastUserVoting', () => {
    it('should return last voting id', async () => {
      token = await ERC20.new('test', 'tst', 1000);
      customToken = await CustomToken.new('test', 'tst', 1000);
      const zeroOneVm = await ZeroOneVM.new();
      await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
      zeroOne = await ZeroOne.new(token.address);
      let formula = "erc20{%s}->conditions{quorum>50%, positive>90% of quorum}"
      await uploadQuestions(formula, zeroOne);
      await startVoting(zeroOne, token);

      await increase(web3, 320000);
      await zeroOne.submitVoting();

      await startVoting(zeroOne, token);

      await zeroOne.setVote(1);
      const lastVoting = await zeroOne.findLastUserVoting(token.address, from);
      console.log(lastVoting.toNumber());
    });
  })

  describe('isUserReturnTokens', ()=>{
    it('should return false', async() => {
      token = await ERC20.new('test', 'tst', 1000);
      customToken = await CustomToken.new('test', 'tst', 1000);
      const zeroOneVm = await ZeroOneVM.new();
      await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
      zeroOne = await ZeroOne.new(token.address);
      let formula = "erc20{%s}->conditions{quorum>50%, positive>90% of quorum}"
      await uploadQuestions(formula, zeroOne);
      await startVoting(zeroOne, token);
      await zeroOne.setVote(1);

      await increase(web3, 320000);
      const isReturn = await zeroOne.isUserReturnTokens(token.address, from);
      console.log(isReturn);
    })

    it('should return true', async() => {
      token = await ERC20.new('test', 'tst', 1000);
      customToken = await CustomToken.new('test', 'tst', 1000);
      const zeroOneVm = await ZeroOneVM.new();
      await ZeroOne.link("ZeroOneVM", zeroOneVm.address);
      zeroOne = await ZeroOne.new(token.address);
      let formula = "erc20{%s}->conditions{quorum>50%, positive>90% of quorum}"
      await uploadQuestions(formula, zeroOne);
      await startVoting(zeroOne, token);

      await zeroOne.setVote(1);
      const userBalance = await token.balanceOf(from);
      const contractBalance = await token.balanceOf(zeroOne.address);

      console.log(userBalance.toNumber(), contractBalance.toNumber());
      await token.transferFrom(zeroOne.address, from, contractBalance.toNumber());
      // await zeroOne.revoke();
      await increase(web3, 320000);
      const isReturn = await zeroOne.isUserReturnTokens(token.address, from);
      console.log(isReturn);
    })
  })

  describe("erc20{%s}->conditions{quorum>50%, positive>90% of quorum}", () => {
    it('should be positive', async () => {
      // let formula = `erc20{%s}->conditions{quorum>50%, positive>90% of quorum}`;
      // let descision;
      // let data = {
      //   "transfers": {
      //     "before":[{
      //       "from": "",
      //       "to": "",
      //       "amount": ""
      //     }],
          
      //     "after": [{
      //       "from": "",
      //       "to": "",
      //       "amount": ""
      //     }]
      //   },
      
      //   "votes":[
      //     {
      //       "sender":"",
      //       "vote":""
      //     }
      //   ],
      //   "expected":""
      // }

      // try {
      //   descision = await Voter(formula);
      // } catch({ message }) {
      //   console.log(message)
      // }
      // assert.strictEqual(descision, 1);  
    });

    it('should be negative', async () => {});

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>50%, positive=100% of quorum}", () => {
    it('should be positive', async () => {});

    it('should be negative', async () => {});

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>0%, positive>50% of all}", () => {
    it('should be positive', async () => {});

    it('should be negative', async () => {});

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>50%,positive>90% of quorum} or custom{%t}->admin", () => {
    it('should be positive', async () => {});

    it('should be negative', async () => {});

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>0%,positive>90% of quorum} and custom{%t}->admin", () => {
    it('should be positive', async () => {});

    it('should be negative', async () => {});

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>30%, positive>50% of all} and (custom{%t}->conditions{quorum>30%, positive>50% of all} and custom{%t}->admin)", () => {
    it('should be positive', async () => {});

    it('should be negative', async () => {});

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->user{%u}->conditions{quorum>0%, positive>50% of all}", () => {
    it('should be positive', async () => {});

    it('should be negative', async () => {});
    
    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>50%, positive>90% of quorum}", () => {
    it('should be positive', async () => {

    });

    it('should be negative', async () => {

    });

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>50%, positive>90% of quorum}", () => {
    it('should be positive', async () => {

    });

    it('should be negative', async () => {

    });

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>50%, positive>90% of quorum}", () => {
    it('should be positive', async () => {

    });

    it('should be negative', async () => {

    });

    it('should be undefined', async () => {});
  });

  describe("erc20{%s}->conditions{quorum>50%, positive>90% of quorum}", () => {
    it('should be positive', async () => {

    });

    it('should be negative', async () => {

    });

    it('should be undefined', async () => {});
  });

});