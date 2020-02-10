const Questions = artifacts.require('QuestionsWithGroups.sol');

module.exports = async function(deployer, network, accounts) {
    const config = {
        from: accounts[0],
    };
    return deployer.deploy(Questions, config)
        .then(() => {
            let output = new String();
            output += '---------------------------------------------------------------------------\n';
            output += `| Questions                  | ${Questions.address} |\n`;
            output += '---------------------------------------------------------------------------';
            console.log(output);
        })
        .catch(console.log.bind(console));
};
