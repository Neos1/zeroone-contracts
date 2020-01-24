const randomInt = (min, max) => {
    const roundedMin = Math.ceil(min);
    const roundedMax = Math.floor(max);
    return Math.floor(Math.random() * (roundedMax - roundedMin + 1)) + roundedMin;
};

const randomRange = (min, max, amount) => {
    const output = [];
    while (output.length < amount) {
        output.push(randomInt(min, max));
    }
    return output;
}

const uniqRandomRange = (min, max, amount) => {
    const output = [];
    while (output.length < amount) {
        let num = randomInt(min, max);
        if (output.indexOf(num) === -1) output.push(num);
    }
    return output;
}

module.exports = {
    randomInt,
    randomRange,
    uniqRandomRange,
};
