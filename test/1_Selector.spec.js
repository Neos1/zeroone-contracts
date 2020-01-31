const SelectorMock = artifacts.require('./SelectorMock.sol');
const QuestionsWithGroups = artifacts.require('./QuestionsWithGroups.sol');

const { randomInt } = require('./helpers/random');

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

    const getGroupCall = {
        "inputs": [
            {
              "components": [
                {
                  "internalType": "string",
                  "name": "name",
                  "type": "string"
                }
              ],
              "internalType": "struct GroupType.Group",
              "name": "_questionGroup",
              "type": "tuple"
            }
          ],
          "name": "addQuestionGroup",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "id",
              "type": "uint256"
            }
          ],
          "stateMutability": "nonpayable",
          "type": "function"
    }

    const selector = web3.eth.abi.encodeFunctionSignature(call);
    const addGroupSelector = web3.eth.abi.encodeFunctionSignature(getGroupCall);
    
    beforeEach(async () => {
        selectorMock = await SelectorMock.new({ from: deployFrom });
        questionsWithGroups = await QuestionsWithGroups.new({from: deployFrom});
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

        it('should return method selector when data is empty', async () => {
            for (let i = 1; i < 10; i++) {
                const value = `0x`
                const result = await selectorMock.testSelector(addGroupSelector, value)
                assert.strictEqual(addGroupSelector, result);
            }
        });
    });

    describe('makeCall()', () => {
        it('should successfully call method from contract', async () => {
            for (let i = 1; i < 10; i++) {
                const value = `test ${i}`
                const {address} = questionsWithGroups;
                const encodedValue = web3.eth.abi.encodeParameters(['tuple(string)'], [[value]]);
                await selectorMock.testMakeCall(addGroupSelector, address, encodedValue);
                const group = await questionsWithGroups.getQuestionGroup(i);
                assert.strictEqual(value, group.name);
            }
        });
    });
});
