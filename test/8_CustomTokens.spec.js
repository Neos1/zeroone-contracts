const CustomToken = artifacts.require('./CustomToken.sol');

const getErrorMessage = require('./helpers/get-error-message');


contract('CustomToken', (accounts) => {
  let token;
  const [from] = accounts;
  const params = ['test', 'tst', 1000];
  const address = '0x68c0c7f9534e7b5fde6a4ca6b00b4ed5b958242a';


  beforeEach(async () => {
    token = await CustomToken.new( ...params, { from });
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
  
  describe('_transfer()',() => {
    it('should transfer tokens beetween users', async () => {
      const admin = await token.owner();
      token._transfer(admin, address, 100);
      const userBalance = await token.balanceOf(address);
      assert.strictEqual(Number(userBalance), 100);
    });

    it('should fail on transfer from empty address', async () => {
      try {
        await token._transfer('0x', address, 100);
      } catch ({ message }) {
        assert.strictEqual(message, 'invalid address (arg="_sender", coderType="address", value="0x")');
      }
    });

    it('should fail on transfer to empty address', async () => {
      const admin = await token.owner();
      try {
        await token._transfer(admin, '0x', 100);
      } catch ({ message }) {
        assert.strictEqual(message, 'invalid address (arg="_recipient", coderType="address", value="0x")');
      }
    });
  });

  describe('transferToAdmin()',() => {
    it('should successfully transfer tokens to admin', async () => {
      const admin = await token.owner();
      await token._transfer(admin, address, 100);
      await token._transferToAdmin(address, 50);
      const adminBalance = await token.balanceOf(admin);
      const userBalance = await token.balanceOf(address);
      assert.strictEqual(Number(userBalance), 50);
      assert.strictEqual(Number(adminBalance), 950);
    });

    it('should fail by calling transfer not from admin', async () => {
      const admin = await token.owner();
      await token._transfer(admin, address, 100);
      try {
        await token.setAdmin(address);
        await token._transferToAdmin(address, 50);
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Ownable: caller is not the owner'));
      }
    });
  });

  describe('transferToUser()',() => {
    it('should successfrully transfer tokens from admin to user', async () => {
      await token._transferToUser(address, 50);
      const userBalance = await token.balanceOf(address);
      assert.strictEqual(Number(userBalance), 50);
    });

    it('should fail on transferring tokens to empty user', async () => {
      try {
        await token._transferToUser('0x', 50);
      } catch ({ message }) {
        assert.strictEqual(message, 'invalid address (arg="_to", coderType="address", value="0x")')
      }
    });

    it('should fail on transferring tokens without admin privileges', async () => {
      await token._transferToUser(address, 50);
      const userBalance = await token.balanceOf(address);
      assert.strictEqual(Number(userBalance), 50);

      await token.setAdmin(address);

      try {
        await token._transferToUser(address, 50, {from});
      } catch ({ message }) {
        assert.strictEqual(message, getErrorMessage('Ownable: caller is not the owner'));
      }
    });
  });

  describe('transferToVoting()',() => {

  });

  describe('isProjectAddress()',() => {

  });


  describe('events', () => {

  });
  
});