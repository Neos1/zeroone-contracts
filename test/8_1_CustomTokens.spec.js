const CustomToken = artifacts.require('./CustomToken.sol');
const ZeroOne = artifacts.require('./ZeroOne.sol');

const getErrorMessage = require('./helpers/get-error-message');


contract('CustomToken', (accounts) => {
  let token;
  let zeroOne;
  let admin;
  const [from, secondary] = accounts;
  const params = ['test', 'tst', 1000];
  const address = '0x68c0c7f9534e7b5fde6a4ca6b00b4ed5b958242a';


  beforeEach( async () => {
    token = await CustomToken.new( ...params, { from });
    zeroOne = await ZeroOne.new({from});
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

  describe('addToProjects()', () => {
    it('should add address in project list', async () => {

    });

    it('should fail on adding empty address to projects list', async () => {

    });

    it('should fail on adding address to projects list, if sender not owner', async () => {

    });


  });

  describe('removeFromProjects()', () => {
    it('should remove address from projects list', async () => {

    });

    it('should fail on removing address from projects list, if sender not project', async () => {

    });
  });

  describe('transferFrom()', () => {
    it('should successfully send tokens between users', async () => {

    });

    it('should successfully lock tokens for project on send vote', async () => {

    });

    it('should fail on send tokens between users, when TX sender not owner or project', async () => {

    });
  });

});