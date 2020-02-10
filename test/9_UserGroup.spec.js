const UserGroupMock = artifacts.require('./UserGroupMock.sol');
const TokenMock = artifacts.require('./TokenMock.sol');
const ERC20Mock = artifacts.require('./ERC20.sol');

const { getShortErrorMessage } = require('./helpers/get-error-message');

contract('UserGroupMock', (accounts) => {
  let userGroup;
  let token;
  let erc20;
  const [from] = accounts;
  const group = {
    name: 'test',
    groupType: 0,
    groupAddress: '0x104184d5E8CD2D830887BAfF03793507dFB2F46a'
  };

  beforeEach(async () => {
    userGroup = await UserGroupMock.new(group);
    token = await TokenMock.new();
    erc20 = await ERC20Mock.new(1000)
  });

  describe('getAdmin()', () => {
    it('should return admin of custom token group', async () => {
      token = await TokenMock.new({from});
      const customGroup = Object.assign(group, {
        groupAddress : token.address,
        groupType: 1,
      });
      userGroup = await UserGroupMock.new(customGroup);
      const admin = await userGroup.testGetAdmin();
      assert.strictEqual(admin.toUpperCase(), from.toUpperCase());
    });

    it('should fail on getting admin of ERC20 group', async () => {
      let error = false
      const ERC20 = Object.assign(group, {
        groupAddress : erc20.address,
        groupType: 0,
      });
      userGroup = await UserGroupMock.new(ERC20);
      
      try {
        await userGroup.testGetAdmin();
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getShortErrorMessage('This is not custom token group'))
      }
      assert.strictEqual(error, true)
    });
  });

  describe('getTotalSupply()', () => {
    it('should return totalSupply token', async () => {
      const ERC20 = Object.assign(group, {
        groupAddress : erc20.address,
        groupType: 0,
      });
      userGroup = await UserGroupMock.new(ERC20);
      const totalSupply = await userGroup.testGetTotalSupply();
      assert.strictEqual(totalSupply.toNumber(), 1000);
    });

    it('should return totalSupply of Custom token', async () => {
      const customGroup = Object.assign(group, {
        groupAddress : token.address,
        groupType: 1,
      });
      userGroup = await UserGroupMock.new(customGroup);
      const totalSupply = await userGroup.testGetTotalSupply();
      assert.strictEqual(totalSupply.toNumber(), 2000)
    });

    it('should return error on non-token totalSupply call', async() => {
      let error = false;
      const nonToken = Object.assign(group, {
        groupAddress : from,
        groupType: 0,
      });

      userGroup = await UserGroupMock.new(nonToken);
      try{
        const totalSupply = await userGroup.testGetTotalSupply();
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getShortErrorMessage('').trim())
      }
      assert.strictEqual(error, true);
    });
  });
});
