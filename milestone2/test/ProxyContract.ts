import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';

describe('Proxy Contract', function () {
	const zeroAddress = '0x0000000000000000000000000000000000000000';

	async function deploy() {
		const [owner, implementation, newImplementation] = await ethers.getSigners();

		const ProxyContract = await ethers.getContractFactory('ProxyContract');
		const proxyContract = await ProxyContract.deploy(implementation);

		return { proxyContract, owner, implementation, newImplementation };
	}

	async function deployWithZeroAddress() {
		const ProxyContract = await ethers.getContractFactory('ProxyContract');
		const proxyContract = await ProxyContract.deploy(zeroAddress);

		return ProxyContract;
	}

	describe('Deployment', () => {
		it('Should set the right owner', async () => {
			const { proxyContract, owner } = await loadFixture(deploy);
			expect(await proxyContract.owner()).to.equal(owner.address);
		});

		it('Should set the right implementation contract', async () => {
			const { proxyContract, implementation } = await loadFixture(deploy);
			expect(await proxyContract.implementation()).to.equal(implementation.address);
		});

		it('Should fail on zero address', async () => {
			await expect(deployWithZeroAddress()).to.be.revertedWith('Zero address');
		});
	});

	describe('Update implementation', () => {
		it('Should set new implementation', async () => {
			const { proxyContract, newImplementation } = await loadFixture(deploy);
			await proxyContract.updateImplementation(newImplementation.address);
			expect(await proxyContract.implementation()).to.equal(newImplementation.address);
		});

		it('Should fail on zero address', async () => {
			const { proxyContract } = await loadFixture(deploy);
			const updateImplementationWithZeroAddress = async () => await proxyContract.updateImplementation(zeroAddress);
			await expect(updateImplementationWithZeroAddress()).to.be.revertedWith('Zero address');
		});
	});
});
