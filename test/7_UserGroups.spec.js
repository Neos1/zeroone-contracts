const UserGroups = artifacts.require('UserGroups.sol');
const TokenMock = artifacts.require('TokenMock.sol');

const { getErrorMessage, getShortErrorMessage } = require('./helpers/get-error-message');

contract('UserGroups', (accounts) => {
  let userGroups;
  const [from] = accounts;
  const group = {
    name: 'test group',
    groupType: 0,
    groupAddress: '0x104184d5E8CD2D830887BAfF03793507dFB2F46a'
  }

  beforeEach(async () => {
    userGroups = await UserGroups.new({ from })
  })

  describe('constructor()', () => {
    it('should successfully created', async () => {
      userGroups = await UserGroups.new({ from });
      let length = await userGroups.getUserGroupsAmount();
      assert.strictEqual(length.toNumber(), 0);
    });
  });

  describe('addGroup()', () => {
    it('should successfully add new user group', async () => {
      await userGroups.addUserGroup(group);
      const {name, groupAddress, groupType} = await userGroups.getUserGroup(0);
      assert.strictEqual(name, group.name)
      assert.strictEqual(groupAddress, group.groupAddress)
      assert.strictEqual(Number(groupType), group.groupType)
    });

    it('should fail on adding user group with non-unique name', async () => {
      let error = false; 
      await userGroups.addUserGroup(group);

      try {
        await userGroups.addUserGroup(group);
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage("Name must be unique"));
      }
      assert.strictEqual(error, true);
    });

    it('should fail on adding user group without address', async () => {
      let error = false; 
      try {
        const wrongGroup = Object.create(group);
        wrongGroup.groupAddress = `0x${Array(40).fill(0).join('')}`;
        await userGroups.addUserGroup(wrongGroup);
      } catch ({message}) {
        assert.strictEqual(message, getErrorMessage('Invalid group'));
        error = true;
      }
      assert.strictEqual(error, true);
    });
  });

  describe('getGroup()', () => {
    it('should get userGroup from list', async () => {
      await userGroups.addUserGroup(group);
      const {name, groupAddress, groupType} = await userGroups.getUserGroup(0);
      assert.strictEqual(name, group.name)
      assert.strictEqual(groupAddress, group.groupAddress)
      assert.strictEqual(Number(groupType), group.groupType)
    });

    it('should fail on getting non-existing group from list', async () => {
      let error = false;
      try {
        await userGroups.getUserGroup(0);
      } catch {
        error = true;
      } 
      assert.strictEqual(error, true);
    });
  });

  describe('getTotalSupply()', () => {
    it('should get totalSupply of Token', async() => {
      const token = await TokenMock.new({from});
      const {address} = token;
      const group = {
        name: 'test',
        groupType: 0,
        groupAddress: address
      }
      await userGroups.addUserGroup(group)
      const balance = await userGroups.getTotalSupply(0)
      assert.strictEqual(balance.toNumber(), 2000);
    });
  })

  describe('getUserGroupAdmin', () => {
    it('should return address of custom token owner', async () => {
      const token = await TokenMock.new({from});
      const {address} = token;
      const group = {
        name: 'test',
        groupType: 1,
        groupAddress: address
      }
      await userGroups.addUserGroup(group)
      const admin = await userGroups.getUserGroupAdmin(0)
      assert.strictEqual(admin, from);
    });

    it('should return error on getting token admin in non-custom tokens', async () => {
      const token = await TokenMock.new({from});
      const {address} = token;
      const group = {
        name: 'test',
        groupType: 0,
        groupAddress: address
      }
      await userGroups.addUserGroup(group)
      try {
        const admin = await userGroups.getUserGroupAdmin(0)
      } catch({ message }) {
        assert.strictEqual(message, getShortErrorMessage('This is not custom token group'));
      }
    });
  })

  describe('events', () => {
    it('should fire event when added new usergroup', async () => {
      const tx = await userGroups.addUserGroup(group);
      const log = tx.logs.find(element => element.event.match('UserGroupAdded'));
      const {args: {name}} = log;
      assert.strictEqual(name, group.name);
    });
  });

});