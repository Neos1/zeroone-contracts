const networks = {
    development: {
        host: "localhost",
        port: 7545,
        network_id: "5777",
    }
};

module.exports = {
    networks,
    compilers: {
        solc: {
            version: "0.6.1",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200,
                }
            }
        }
    },
    plugins: [
        "@neos1/truffle-plugin-docs"
    ]
};