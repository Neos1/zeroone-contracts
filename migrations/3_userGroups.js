const UserGroups = artifacts.require('UserGroups.sol');

module.exports = async function(deployer, network, accounts) {
    const config = {
        from: accounts[0],
    };
    return deployer.deploy(UserGroups, config)
        .then(() => {
            let output = new String();
            output += '---------------------------------------------------------------------------\n';
            output += `| UserGroups                  | ${UserGroups.address} |\n`;
            output += '---------------------------------------------------------------------------';
            console.log(output);
        })
        .catch(console.log.bind(console));
};
