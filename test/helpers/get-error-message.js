const txError = 'Returned error: VM Exception while processing transaction: revert %s -- Reason given: %s.';

module.exports = (message) => {
    return txError.replace(/\%s/g, message);
}