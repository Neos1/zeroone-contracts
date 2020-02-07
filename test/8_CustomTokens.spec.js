const CustomToken = artifacts.require('./CustomToken.sol');

const getErrorMessage = require('./helpers/get-error-message');


contract('CustomToken', (accounts) => {
  let token;
  let admin;
  const [from, secondary] = accounts;
  const params = ['test', 'tst', 1000];
  const address = '0x68c0c7f9534e7b5fde6a4ca6b00b4ed5b958242a';


  beforeEach( async () => {
    token = await CustomToken.new( ...params, { from });
    admin = await token.owner();
  });

  describe('constructor()', () => {
    it('should be successfully created', async () => {
       token = await CustomToken.new( ...params, { from });

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

  describe('setAdmin()',() => {
    it('should change admin of tokens', async() => {
      await token.setAdmin(address);
      const owner = await token.owner();
      assert.strictEqual(owner.toUpperCase(), address.toUpperCase());
    });

    it('should fail on change admin, which address contains in projects', async () => {
      await token.addToProjects(address);
      try {
        await token.setAdmin(address);
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Address used as project'));
      }
    });

    it('should fail on change admin with incorrect address', async () => {
      try {
        await token.setAdmin('0x');
      } catch ({ message }) {
        assert.strictEqual(message, 'invalid address (arg="_newAdmin", coderType="address", value="0x")');
      }
    });

  });
  
  describe('addToProjects', () => {
    it('should successfully add address to projects', async() => {
      const projects = [address]
      await token.addToProjects(address);
      const uploadedProjects = await token.getProjects();
      for (let i = 0; i< uploadedProjects.length; i++) {
        assert.strictEqual((uploadedProjects[i]).toUpperCase(), (projects[i]).toUpperCase());
      }
    });

    it('should fail on adding project with empty address', async () => {
      try {
        await token.addToProjects('0x');
      } catch ({ message }) {
        assert.strictEqual(message, 'invalid address (arg="_project", coderType="address", value="0x")');
      }
    });

    it('should fail on adding project with already existing address', async () => {
      await token.addToProjects(address);
      try {
        await token.addToProjects(address);
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Address already in list'));
      }
    });
  });
  
  describe('transferFrom()',() => {
    it('should successfully transfer tokens to admin', async () => {
      await token.transferFrom(admin, address, 100);
      await token.transferFrom(address, admin, 50);

      const adminBalance = await token.balanceOf(admin);
      const userBalance = await token.balanceOf(address);

      assert.strictEqual(Number(userBalance), 50);
      assert.strictEqual(Number(adminBalance), 950);
    });

    it('should fail by calling transfer not from admin', async () => {
      await token.transferFrom(admin, address, 100);
      try {
        await token.setAdmin(address);
        await token.transferFrom(address, admin, 50);
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Ownable: caller is not the owner'));
      }
    });

    it('should successfrully transfer tokens from admin to user', async () => {
      await token.transferFrom(admin, address, 50);
      const userBalance = await token.balanceOf(address);
      assert.strictEqual(Number(userBalance), 50);
    });

    it('should fail on transferring tokens to empty user', async () => {
      try {
        await token.transferFrom(admin, '0x', 50);
      } catch ({ message }) {
        assert.strictEqual(message, 'invalid address (arg="_to", coderType="address", value="0x")')
      }
    });

    it('should fail on transferring tokens without admin privileges', async () => {
      await token.transferFrom(admin, address, 50);
      const userBalance = await token.balanceOf(address);
      assert.strictEqual(Number(userBalance), 50);

      await token.setAdmin(address);
      const notAdmin = admin;

      try {
        await token.transferFrom(notAdmin, address, 50);
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Ownable: caller is not the owner'));
      }
    });
  });

  describe('sendVote()',() => {
    it('should change balance for project, like user transfer tokens to voting', async () => {
      try {
        const projectAddress = '0x298e231fcf67b4aa9f41f902a5c5e05983e1d5f8'
        await token.addToProjects(projectAddress);
        await token.sendVote(projectAddress, {from: secondary});
        const isTokensBlocked = await token.isTokenLocked(projectAddress, secondary);
        assert.strictEqual(isTokensBlocked, true);
      } catch ({message}) {
        console.log(message);
      }
      
    });

    it('should fail on changing balance for project non-existing in list', async () => {
      const projectAddress = '0x298e231fcf67b4aa9f41f902a5c5e05983e1d5f8'
      await token.addToProjects(projectAddress);
      try {
        await token.sendVote(projectAddress);
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Address is not in project list'));
      }
    });
  });

  describe('isProjectAddress()',() => {
    it('should confirm that address is in projects list', async () => {
      await token.addToProjects(address);
      const isProject = await token.isProjectAddress(address);
      assert.strictEqual(isProject, true);
    });

    it('should confirm that address is not in projects list', async () => {
      const isProject = await token.isProjectAddress(address);
      assert.strictEqual(isProject, false);
    });
  });

  describe('events', () => {
    it('should fire OwnershipTransferred event on admin changing', async () => {
      const tx = await token.setAdmin(address);
      const log = tx.logs.find(element => element.event.match('OwnershipTransferred'));
      const {args: {previousOwner, newOwner}} = log;
      assert.strictEqual(previousOwner.toUpperCase(), from.toUpperCase());
      assert.strictEqual(newOwner.toUpperCase(), address.toUpperCase());
    });

    it('should fire Transfer event on "transferToUser()" call', async () => {
  
      const tx = await token.transferFrom(admin, address, 100);
      const log = tx.logs.find(element => element.event.match('Transfer'));
      const {args: {from: sender, to, count}} = log;
      assert.strictEqual(sender.toUpperCase(), from.toUpperCase());      
      assert.strictEqual(to.toUpperCase(), address.toUpperCase());      
      assert.strictEqual(count.toNumber(), 100);
    });

    it('should fire Transfer event on "transferToAdmin()" call', async () => {
      await token.transferFrom(admin, address, 100);

      const tx = await token.transferFrom(address, admin, 100);
      const log = tx.logs.find(element => element.event.match('Transfer'));
      const {args: {from: sender, to, count}} = log;
      assert.strictEqual(sender.toUpperCase(), address.toUpperCase());      
      assert.strictEqual(to.toUpperCase(), admin.toUpperCase());      
      assert.strictEqual(count.toNumber(), 100);
    });

    it('should fire TokenLocked event on "sendVote()" call', async () => {
      await token.transferFrom(admin, secondary, 100);
      await token.addToProjects(address);

      const tx = await token.sendVote(address, {from: secondary});
      const log = tx.logs.find(element => element.event.match('TokenLocked'));
      const {args: {project, user}} = log;
      assert.strictEqual(project.toUpperCase(), address.toUpperCase());      
      assert.strictEqual(user.toUpperCase(), secondary.toUpperCase());      
    });

  });

});
