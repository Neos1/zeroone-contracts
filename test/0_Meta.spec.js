const MetaMock = artifacts.require('./MetaMock.sol');

const { randomRange, randomInt } = require('./helpers/random');



contract('Meta', (accounts) => {
    let metaMock;
    let questions;
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

        it('should fail when function has no allocated place for meta', async () => {
            let error = false
            const failingParams = ['uint256', 'uint256'];
            const initial = (new Array(1)).fill(0);
            try {
                const value = randomInt(0, 100);
                const replace = randomRange(0, 100, 2);
                const base = web3.eth.abi.encodeParameters(failingParams, [...initial, value]);
                const expected = web3.eth.abi.encodeParameters(params, [...replace, value]);
                const result = await metaMock.testMeta(base, ...replace);
                assert.strictEqual(result, expected);
            } catch {
                error = true;
            };
            assert.strictEqual(error, true);
        });
    });
});
