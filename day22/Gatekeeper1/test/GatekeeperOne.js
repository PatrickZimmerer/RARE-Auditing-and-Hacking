const { expect } = require('chai');
const { BigNumber } = require('ethers');
const { parseEther } = require('ethers/lib/utils');
const { ethers } = require('hardhat');

describe('GatekeeperOne', () => {
	let attackerContract;
	let gatekeeperOne;
	let deployer;
	let account1;

	beforeEach(async () => {
		[depl, acc1] = await ethers.getSigners();

		deployer = depl;
		account1 = acc1;

		// const AttackerFactory = await ethers.getContractFactory('GatekeeperOneAttacker');
		// attackerContract = await AttackerFactory.deploy();
		// await attackerContract.deployed();

		// const GatekeeperOneFactory = await ethers.getContractFactory('GatekeeperOne');
		// gatekeeperOne = await GatekeeperOneFactory.deploy();
		// await gatekeeperOne.deployed();
	});
	describe('get gas', () => {
		it('should get the right amount of gas to put in', async () => {
			for (let i = 0; i < 8191; i++) {
				try {
					attackerContract.enter(i);
					console.log(i);
				} catch {
					return;
				}
			}
		});
	});
});
