const { randomInt } = require('./helpers/random');

const SelectorMock = artifacts.require('./SelectorMock.sol');

contract('Selector', (accounts) => {
    let selectorMock;
    const deployFrom = accounts[0];
    const call = {
        name: 'method',
        type: 'function',
        inputs: [{
            type: 'uint256',
            name: '_param1'
        }]
    };
    const selector = web3.eth.abi.encodeFunctionSignature(call);

    beforeEach(async () => {
        selectorMock = await SelectorMock.new({ from: deployFrom });
    });

    describe('addData()', () => {
        it('should convert provided selector and data to calldata', async () => {
            for (let i = 0; i < 10; i++) {
                const value = randomInt(0, 100);
                const encodedValue = web3.eth.abi.encodeParameters(['uint256'], [value]);
                const expected = web3.eth.abi.encodeFunctionCall(call, [value]);
                const result = await selectorMock.testSelector(selector, encodedValue);
                assert.strictEqual(result, expected);
            }
        });

        // TODO:
        // 1. test makeCall() method
        // 2. edge cases
    })
});
