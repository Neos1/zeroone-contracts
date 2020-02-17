const ZeroOne = artifacts.require('./ZeroOneMock.sol');
const Controlled = artifacts.require('./ControlledMock.sol');
const ERC20 = artifacts.require('./ERC20.sol');

const {questions} = require('./helpers/questions');

contract('ZeroOne', (accounts) => {
    let zeroOne;
    let controlled;
    let token;
    const deployFrom = accounts[0];
    const param1 = 1;
    const param2 = 'test';
    const data = web3.eth.abi.encodeParameters(
        ['tuple(uint256,uint256,uint256,uint256,uint256)', 'uint256', 'string'],
        [[0, 0, 0, 0, 0], param1, param2]
    );
    const metaData = {
        ballotId: 1,
        questionId: 2,
        startBlock: 3,
        endBlock: 4,
        result: 1
    };
    const controlledMethods = Controlled.abi
        .filter(item => item.type === 'function')
        .map((item) => ({
            ...item,
            selector: web3.eth.abi.encodeFunctionSignature(item)
        }))
        .reduce((prev, item) => {
            prev[item.name] = item;
            return prev;
        }, {});

    beforeEach(async () => {
        token = await ERC20.new('test', 'tst', 1000);
        zeroOne = await ZeroOne.new(token.address, { from: deployFrom });
        controlled = await Controlled.new(zeroOne.address, { from: deployFrom });
    });

    describe('makeCall()', () => {
        it('should successfully update controlled params', async () => {
            await zeroOne.testMakeCall(
                controlled.address,
                controlledMethods.testSuccess.selector,
                data,
                metaData
            );
            const stored1 = await controlled.param1();
            const stored2 = await controlled.param2();
            assert.strictEqual(stored1.toNumber(), param1);
            assert.strictEqual(stored2, param2);
        });

        it('should handle revert', async () => {
            await zeroOne.testMakeCall(
                controlled.address,
                controlledMethods.testRevert.selector,
                data,
                metaData
            );
            const stored1 = await controlled.param1();
            const stored2 = await controlled.param2();
            assert.strictEqual(stored1.toNumber(), 0);
            assert.strictEqual(stored2, '');
        });
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
        it('should make all voting process', async () => {
            for (let i = 0; i < questions.length; i++) {
                questions[i].target = zeroOne.address;
                questions[i].active = true;
                await zeroOne.addQuestion(questions[i]);
            }
            const data = web3.eth.abi.encodeParameters(['string'], ["test"])
            const votingData = {
                questionId: 2,
                starterAddress: deployFrom,
                starterGroupId: 0,
                endTime: 0,
                data,
            }
            await zeroOne.startVoting(votingData);
            const voting = await zeroOne.getVoting(0);
            
        });
    });

    describe('events', () => {
        it('should fire Call event after successful call', async () => {
            const { selector } = controlledMethods.testSuccess;
            const tx = await zeroOne.testMakeCall(
                controlled.address,
                selector,
                data,
                metaData
            );
            const callData = web3.eth.abi.encodeParameters(
                ['tuple(uint256,uint256,uint256,uint256,uint256)', 'uint256', 'string'],
                [Object.values(metaData), param1, param2]
            );
            const log = tx.logs.find(element => element.event.match('Call'));
            assert.strictEqual(log.args.selector, selector);
            assert.strictEqual(log.args.data, callData);
            assert.strictEqual(log.args.result, true);
            assert.strictEqual(log.args.response, null);
        });

        it('should fire Call event after fail call', async () => {
            const { selector } = controlledMethods.testRevert;
            const tx = await zeroOne.testMakeCall(
                controlled.address,
                selector,
                data,
                metaData
            );
            const callData = web3.eth.abi.encodeParameters(
                ['tuple(uint256,uint256,uint256,uint256,uint256)', 'uint256', 'string'],
                [Object.values(metaData), param1, param2]
            );
            const log = tx.logs.find(element => element.event.match('Call'));
            assert.strictEqual(log.args.selector, selector);
            assert.strictEqual(log.args.data, callData);
            assert.strictEqual(log.args.result, false);
            assert.strictEqual(log.args.response, null);
        });

        it('should fire Call event after fail call with revert message', async () => {
            const { selector } = controlledMethods.testRevertMessage;
            const tx = await zeroOne.testMakeCall(
                controlled.address,
                selector,
                data,
                metaData
            );
            const callData = web3.eth.abi.encodeParameters(
                ['tuple(uint256,uint256,uint256,uint256,uint256)', 'uint256', 'string'],
                [Object.values(metaData), param1, param2]
            );
            const log = tx.logs.find(element => element.event.match('Call'));
            const message = web3.utils.toAscii(log.args.response);
            assert.strictEqual(log.args.selector, selector);
            assert.strictEqual(log.args.data, callData);
            assert.strictEqual(log.args.result, false);
            assert.strictEqual(message.includes('test'), true);
        });
    })
});
