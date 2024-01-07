import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { ImplContract } from '../typechain-types';

describe('Implementation Contract', () => {
    async function deploy() {
        const [user] = await ethers.getSigners();

        const initialPrice = 1;
        const initialMinTokenAmount = 5;
        const initialFeePercentage = 5;

        const ImplementationContract = await ethers.getContractFactory('ImplContract');
        const implContract: ImplContract = await ImplementationContract.deploy(
            initialPrice,
            initialMinTokenAmount,
            initialFeePercentage
        );

        return {
            implContract,
            initialPrice,
            initialMinTokenAmount,
            initialFeePercentage,
            user
        };
    }

    async function getUserBalance(contract: ImplContract, userAddress: string): Promise<bigint> {
        return await contract.balanceOf(userAddress);
    }

    describe('Deploy', () => {
        it('Should set initial price', async () => {
            const { implContract, initialPrice } = await loadFixture(deploy);
            expect(await implContract.tokenPrice()).to.equal(initialPrice);
        });

        it('Should set initial min token amount', async () => {
            const { implContract, initialMinTokenAmount } = await loadFixture(deploy);
            expect(await implContract.minTokenAmount()).to.equal(initialMinTokenAmount);
        });

        it('Should set initial fee percentage', async () => {
            const { implContract, initialFeePercentage } = await loadFixture(deploy);
            expect(await implContract.feePercentage()).to.equal(initialFeePercentage);
        });
    });

    describe('totalSupply function', () => {
       it('Should return the correct total supply', async () => {
           const { implContract } = await loadFixture(deploy);
           expect(await  implContract.totalSupply()).to.equal(0);
       });
    });

    describe('balanceOf function', () => {
        it('Should return the correct user balance', async () => {
            const { implContract, user } = await loadFixture(deploy);
            expect(await  implContract.balanceOf(user.address)).to.equal(0);
        });
    });

    describe('transfer function', () => {
        it('Should fail if sender balance is less then provided amount', async () => {
            const { implContract, user } = await loadFixture(deploy);
            expect(await implContract.transfer(user.address, 0)).to.be.revertedWith('Insufficient balance');
        });

        it('Should increase receiver balance', async () => {

        });

        it('Should decrease sender balance', async () => {

        });

        it('Should emit Transfer event and return true', async () => {

        });
    });
});
