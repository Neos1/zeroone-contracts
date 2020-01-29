const UniqueMock = artifacts.require('./UniqueMock.sol');

contract('Unique', (accounts) => {
  let uniqueMock;
  const deployFrom = accounts[0];

  beforeEach(async () => {
    uniqueMock = await UniqueMock.new({ from: deployFrom });
  });

  describe('add()', () => {
    it('should add names to list', async () => {
      let error = false
      try {
        await uniqueMock.testAdd('test');
        await uniqueMock.testAdd('test1');
      } catch (e) {
        error = true
      }
      assert.strictEqual(error, false);
    });

    it('should fail on non-unique name', async () => {
      let error = false
      try {
        await uniqueMock.testAdd('test');
        await uniqueMock.testAdd('test');
      } catch (e) {
        error = true
      }
      assert.strictEqual(error, true);
    })
  });

})