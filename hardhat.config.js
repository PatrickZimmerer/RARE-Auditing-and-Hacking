require('@nomicfoundation/hardhat-toolbox');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: {
		compilers: [
			{ version: '0.8.1' },
			{ version: '0.8.0' },
			{ version: '0.7.6' },
			{ version: '0.4.21' },
		],
	},
};
