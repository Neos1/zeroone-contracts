const CustomToken = artifacts.require('./CustomToken.sol');
// const ZeroOne = artifacts.require('./ZeroOneMock.sol');

const { getErrorMessage } = require('./helpers/get-error-message');
const increase = require('./helpers/increase-time');

contract('CustomToken', (accounts) => {
  let token;
  let zeroOne;
  let admin;
  const [from, secondary] = accounts;
  const params = ['test', 'tst', 1000];
  let address = '0x68c0c7f9534e7b5fde6a4ca6b00b4ed5b958242a';


  beforeEach( async () => {
    token = await CustomToken.new( ...params, { from });
    // zeroOne = await ZeroOne.new({from});
    admin = await token.owner();
  });

  describe('constructor()', () => {
    it('should be successfully created', async () => {
       token = await CustomToken.new( ...params, { from });
       console.log(token.address)

       const [name, symbol, totalSupply] = params;
       const tokenName = await token.name();
       const tokenSymbol = await token.symbol();
       const tokenSupply = await token.totalSupply();
       const owner = await token.owner();

       assert.strictEqual(tokenName, name);
       assert.strictEqual(tokenSymbol, symbol);
       assert.strictEqual(Number(tokenSupply), totalSupply);
       assert.strictEqual(owner, from);
    });
  });

  describe('transferOwnership', () => {
    it('should tranfer ownership by ZeroOne Call', async () => {
      await token.addToProjects(zeroOne.address);
      await zeroOne.setGroupAdmin(token.address, secondary);
      const admin = await token.owner();
      assert.strictEqual(admin.toUpperCase(), secondary.toUpperCase());
    });

    it('should fail on call ownership transferring when sender is not ZeroOne', async () => {
      let error = false;
      try {
        await token.transferOwnership(secondary);
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage("Project list does not contain provided address"))
      }
      assert.strictEqual(error, true);
    });
  })

  describe('addToProjects()', () => {
    it('should add address in project list', async () => {
      await token.addToProjects(zeroOne.address);
      const isProject = await token.isProjectAddress(zeroOne.address);
      assert.strictEqual(isProject, true);
    });

    it('should fail on adding empty address to projects list', async () => {
      const address = `0x${Array(40).fill(0).join('')}`
      let error = false;
      try {
        await token.addToProjects(address);
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage("Address must be non-empty"))
      }
      assert.strictEqual(error, true);
    });

    it('should fail on adding address to projects list, if sender not owner', async () => {
      let error = false;
      try {
        await token.addToProjects(address, {from: secondary});
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage("Ownable: caller is not the owner"))
      }
      assert.strictEqual(error, true);
    });

    it('should fail on adding address which already in projects list', async () => {
      let error = false;
      await token.addToProjects(zeroOne.address);
      try {
        await token.addToProjects(zeroOne.address);
      } catch ({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage("Project is already in the list"))
      }
      assert.strictEqual(error, true);
    });
  });

  describe('removeFromProjects()', () => {
    it('should remove address from projects list', async () => {
      await token.addToProjects(zeroOne.address);
      let isProject = await token.isProjectAddress(zeroOne.address);
      assert.strictEqual(isProject, true);

      await zeroOne.disableUserGroup(token.address);
      isProject = await token.isProjectAddress(zeroOne.address);
      assert.strictEqual(isProject, false);
    });

    it('should fail on removing address from projects list, if sender not project', async () => {
      await token.addToProjects(zeroOne.address);
      let isProject = await token.isProjectAddress(zeroOne.address);
      let error = false;
      assert.strictEqual(isProject, true);
      try {
        await token.removeFromProjects(zeroOne.address, {from});
        isProject = await token.isProjectAddress(zeroOne.address);
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage("Project list does not contain provided address"));
      }
      assert.strictEqual(error, true);
    });

    it('should fail on removing project which not in projects list', async () => {
      let isProject = await token.isProjectAddress(zeroOne.address);
      assert.strictEqual(isProject, false);
      await zeroOne.disableUserGroup(token.address);
      const events = await token.getPastEvents('ProjectRemoved')
      assert.strictEqual(events.length, 0);
    });
  });

  describe('transferFrom()', () => {
    it('should successfully send tokens between users', async () => {
      const admin = from;
      await token.transferFrom(admin, secondary, 300);
      const balance = await token.balanceOf(secondary);
      assert.strictEqual(balance.toNumber(), 300)
    });

    it('should successfully keep admin priveledges, if admin send all of tokens to users', async () => {
      const admin = from;
      const tx = await token.transferFrom(admin, secondary, 1000)
      const log = tx.logs.find(element => element.event.match('HolderRemoved'));
      const {args: {holder}} = log;
      assert.strictEqual(holder, admin); // check, if admin removed from holders list

      let adminBalance = await token.balanceOf(admin)
      const groupAdmin = await token.owner();
      assert.strictEqual(groupAdmin, admin); // check group adminstrator
      assert.strictEqual(adminBalance.toNumber(), 0); // check group adminstrator balance

      await token.transferFrom(secondary, admin, 300); // trying transfer from user to admin
      adminBalance = await token.balanceOf(admin);
      assert.strictEqual(adminBalance.toNumber(), 300); // check group adminstrator balance again
    });

    it('should fail on tranfer tokens, which count greater, then sender balance', async () => {
      let error = false;
      try {
        await token.transferFrom(from, secondary, 1100);
      } catch({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage('Value must be less or equal user balance'))
      }
      assert.strictEqual(error, true);
    });

    it('should successfully lock tokens for project on send vote', async () => {
      await token.addToProjects(zeroOne.address);
      await zeroOne.setVote(token.address, from, 1);
      const isLocked =  await token.isTokenLocked(zeroOne.address, from);
      assert.strictEqual(isLocked, true);
    });

    it('should successfully lock tokens for 2 project in same time', async () => {
      const secondZeroOne = await ZeroOne.new({from});

      await token.addToProjects(zeroOne.address);
      await token.addToProjects(secondZeroOne.address);

      await zeroOne.setVote(token.address, from, 1);
      await secondZeroOne.setVote(token.address, from, 1);

      const isLockedFirst =  await token.isTokenLocked(zeroOne.address, from);
      const isLockedSecond =  await token.isTokenLocked(secondZeroOne.address, from);

      assert.strictEqual(isLockedFirst, true);
      assert.strictEqual(isLockedSecond, true);
    });

    it('should fail on tokens lock if they are already locked', async () => {
      let error = false;
      await token.addToProjects(zeroOne.address);
      await zeroOne.setVote(token.address, from, 1);
      const isLocked =  await token.isTokenLocked(zeroOne.address, from);
      assert.strictEqual(isLocked, true);
      try {
        await zeroOne.setVote(token.address, from, 1);
      } catch({message}) {
        error = true;
        assert.strictEqual(message, getErrorMessage('Tokens in this project is already locked'))
      }
      assert.strictEqual(error, true);
    });

    it('should fail on lock tokens for project when balance is zero', async () => {
      let error = false;

      await token.addToProjects(zeroOne.address);
      try {
        await zeroOne.setVote(token.address, secondary, 1);
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage('Balance of sender must be greater, then zero'))
      }
      assert.strictEqual(error, true);
    });

    it('should fail on send tokens between users, when TX sender not owner or project', async () => {
      let error = false;
      await token.transferFrom(from, secondary, 300);
      try {
        await token.transferFrom(from, secondary, 300, {from: secondary});
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage('This operation is not allowed for this address'));
      }
      assert.strictEqual(error, true);
    });
  });

  describe('revoke', () => {
    it('should revoke tokens from project', async () => {
      await token.addToProjects(zeroOne.address);
      await zeroOne.setVote(token.address, from, 1);
      await token.revoke(zeroOne.address);

      const isLocked =  await token.isTokenLocked(zeroOne.address, from);
      const isUserVoted = await zeroOne.getUserVote(token.address, from);
      const userVoteWeight = await zeroOne.getUserVoteWeight(token.address, from);

      assert.strictEqual(isLocked, false);
      assert.strictEqual(isUserVoted.toNumber(), 0);
      assert.strictEqual(userVoteWeight.toNumber(), 0);
    });

    it('should revoke tokens and keep info about user vote', async () => {
      await token.addToProjects(zeroOne.address);
      await zeroOne.setVote(token.address, from, 1);
      increase(web3, 3200000);

      await zeroOne.submitVoting();
      await token.revoke(zeroOne.address);

      const isLocked =  await token.isTokenLocked(zeroOne.address, from);
      const isUserVoted = await zeroOne.getUserVote(token.address, from);
      const userVoteWeight = await zeroOne.getUserVoteWeight(token.address, from);

      assert.strictEqual(isLocked, false);
      assert.strictEqual(isUserVoted.toNumber(), 1);
      assert.strictEqual(userVoteWeight.toNumber(), 1000);
    });

    it('should fail on revoke tokens, when user not vote', async () => {
      let error = false;
      await token.addToProjects(zeroOne.address);
      try {
        await token.revoke(zeroOne.address);
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage('User not voted, nothing to unlock'));
      }
      assert.strictEqual(error, true);
    });

    it('should fail on revoke token from address, which is not a project', async () => {
      let error = false;
      try {
        await token.revoke(zeroOne.address);
      } catch ({ message }) {
        error = true;
        assert.strictEqual(message, getErrorMessage('Address is not in project list'));
      }
      assert.strictEqual(error, true);
    });
  });

  describe('events', () => {
    it('should emit OwnershipTransferred', async () => {
      const token = await CustomToken.new( ...params, { from });
      const [event] = await token.getPastEvents("OwnershipTransferred");
      const {args: {previousOwner, newOwner}} = event;
      assert.strictEqual(previousOwner, `0x${Array(40).fill(0).join('')}`);
      assert.strictEqual(newOwner, from);
    });

    it('should emit Transfer', async () => {
      const tx = await token.transferFrom(from, secondary, 100)
      const log = tx.logs.find(element => element.event.match('Transfer'));
      const {args: {from:sender, to, count}} = log;
      assert.strictEqual(sender, from);
      assert.strictEqual(to, secondary);
      assert.strictEqual(count.toNumber(), 100);
    });

    it('should emit HolderRemoved', async () => {
      await token.transferFrom(from, secondary, 100);
      const tx = await token.transferFrom(secondary, from, 100)
      const log = tx.logs.find(element => element.event.match('HolderRemoved'));
      const {args: {holder}} = log;
      assert.strictEqual(holder, secondary);
    });

    it('should emit HolderAdded', async () => {
      const tx = await token.transferFrom(from, secondary, 100)
      const log = tx.logs.find(element => element.event.match('HolderAdded'));
      const {args: {holder}} = log;
      assert.strictEqual(holder, secondary);
    });

    it('should emit ProjectAdded', async () => {
      const tx = await token.addToProjects(zeroOne.address);
      const log = tx.logs.find(element => element.event.match('ProjectAdded'));
      const {args: {project}} = log;
      assert.strictEqual(project, zeroOne.address);
    });

    it('should emit ProjectRemoved', async () => {
      await token.addToProjects(zeroOne.address);
      await zeroOne.disableUserGroup(token.address);
      const [event] = await token.getPastEvents('ProjectRemoved');
      const {args: {project}} = event;
      assert.strictEqual(project, zeroOne.address);
    });

    it('should emit TokensLocked', async () => {
      await token.addToProjects(zeroOne.address);
      const tx = await zeroOne.setVote(token.address, from, 1);
      const [event] = await token.getPastEvents('TokensLocked')
      const {args: {project, user}} = event;
      assert.strictEqual(project, zeroOne.address);
      assert.strictEqual(user, from);
    });
  });
});
