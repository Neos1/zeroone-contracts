const { randomRange, randomInt } = require('./helpers/random');

const MetaMock = artifacts.require('./MetaMock.sol');

contract('Meta', (accounts) => {
    let metaMock;
    const deployFrom = accounts[0];
    const params = ['uint256', 'uint256', 'uint256'];

    beforeEach(async () => {
        metaMock = await MetaMock.new({ from: deployFrom });
    });

    describe('addMetadata()', () => {
        it('should replace first 2 params with provided', async () => {
            const initial = (new Array(2)).fill(0);
            for (let i = 0; i < 10; i++) {
                const value = randomInt(0, 100);
                const replace = randomRange(0, 100, 2);
                const base = web3.eth.abi.encodeParameters(params, [...initial, value]);
                const expected = web3.eth.abi.encodeParameters(params, [...replace, value]);
                const result = await metaMock.testMeta(base, ...replace);
                assert.strictEqual(result, expected);
            }
        });

        // TODO:
        // 1. test case when provided function has no allocated place for meta
    })
});
