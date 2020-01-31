const UserGroups = artifacts.require('UserGroups.sol');

const getErrorMessage = require('./helpers/get-error-message');

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

  describe('addGroup()', () => {
    it('should successfully add new user group', async () => {
      let length = await userGroups.getUserGroupsAmount();
      assert.strictEqual(length.toNumber(), 0);
      await userGroups.addGroup(group);
      const {name, groupAddress, groupType} = await userGroups.getGroup(0);
      assert.strictEqual(name, group.name)
      assert.strictEqual(groupAddress, group.groupAddress)
      assert.strictEqual(Number(groupType), group.groupType)
    });

    it('should fail on adding user group with non-unique name', async () => {
      let error = false; 
      try {
        await userGroups.addGroup(group);
        await userGroups.addGroup(group);
      } catch {
        error = true;
      }
      assert.strictEqual(error, true);
    });

    it('should fail on adding user group without address', async () => {
      let error = false; 
      try {
        const wrongGroup = Object.create(group);
        wrongGroup.groupAddress = '0x';
        await userGroups.addGroup(wrongGroup);
      } catch {
        error = true;
      }
      assert.strictEqual(error, true);
    });
  });

  describe('getGroup()', () => {
    it('should get userGroup from list', async () => {
      await userGroups.addGroup(group);
      const {name, groupAddress, groupType} = await userGroups.getGroup(0);
      assert.strictEqual(name, group.name)
      assert.strictEqual(groupAddress, group.groupAddress)
      assert.strictEqual(Number(groupType), group.groupType)
    });

    it('should fail on getting non-existing group from list', async () => {
      let error = false;
      try {
        await userGroups.getGroup(0);
      } catch ({ message }) {
        error = true
      } 
      assert.strictEqual(error, true);
    });

  })
})