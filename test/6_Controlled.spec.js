const ZeroOne = artifacts.require('./ZeroOneMock.sol');
const Controlled = artifacts.require('./ControlledMock.sol');

contract('ZeroOne', (accounts) => {
    let zeroOne;
    let controlled;
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
        zeroOne = await ZeroOne.new({ from: deployFrom });
        controlled = await Controlled.new(zeroOne.address, { from: deployFrom });
        //console.log(controlledMethods);
    });

    describe('events', () => {
        it('should fire ZeroOneCall event after successful call', async () => {
            const {address} = controlled;
            const {testSuccess: {selector}} = controlledMethods;

            await zeroOne.testMakeCall(address, selector, data, metaData);

            const [event] = await controlled.getPastEvents("ZeroOneCall");
            const {ballotId, questionId, startBlock, endBlock, result} = event.args.meta;
            assert.strictEqual(Number(ballotId), metaData.ballotId);
            assert.strictEqual(Number(questionId), metaData.questionId);
            assert.strictEqual(Number(startBlock), metaData.startBlock);
            assert.strictEqual(Number(endBlock), metaData.endBlock);
            assert.strictEqual(Number(result), metaData.result);
        });

        it('should not fire ZeroOneCall event after failed call', async () => {
            const {address} = controlled;
            const {testRevert: {selector}} = controlledMethods;

            await zeroOne.testMakeCall(address, selector, data, metaData);

            const events = await controlled.getPastEvents("ZeroOneCall");
            assert.strictEqual(events.length, 0);
        });

        it('should revert with message', async () => {
            const {address} = controlled;
            const {testRevertMessage: {selector}} = controlledMethods;
            const tx = await zeroOne.testMakeCall(address, selector, data, metaData);
            const log = tx.logs.find(element => element.event.match('Call'));
            const message = web3.utils.toAscii(log.args.response);
            assert.strictEqual(log.args.selector, selector);
            assert.strictEqual(log.args.result, false);
            assert.strictEqual(message.includes('test'), true);
        });
    })
});
