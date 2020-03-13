const CustomToken = artifacts.require('CustomToken.sol');

module.exports = async function(deployer, network, accounts) {
    const config = {
        from: accounts[0],
    };
    return deployer.deploy(CustomToken, "test", "tst", 1000, config)
        .then(() => {
            let output = new String();
            output += '---------------------------------------------------------------------------\n';
            output += `| CustomToken                  | ${CustomToken.address} |\n`;
            output += '---------------------------------------------------------------------------';
            console.log(output);
        })
        .catch(console.log.bind(console));
};
