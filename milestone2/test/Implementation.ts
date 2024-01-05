import { expect } from 'chai';
import hre, { ethers } from 'hardhat';
import { time } from '@nomicfoundation/hardhat-toolbox/network-helpers';

describe('Implementation', function () {
	it('Should set the right unlockTime', async function () {
		const lockedAmount = 1_000_000_000;
		const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
		const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

		const lock = await ethers.deployContract('Impl', [unlockTime], {
			value: lockedAmount,
		});

		expect(await lock.unlockTime()).to.equal(unlockTime);
	});
});
