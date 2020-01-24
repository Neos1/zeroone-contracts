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
    });

    describe('events', () => {
        it('should fire ZeroOneCall event after successful call', async () => {
            // TODO: test event
        });
    })
});
