import { expect } from 'chai';
import { ethers } from 'hardhat';
import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { ImplContract } from '../typechain-types';

describe('Implementation Contract', () => {
    const zeroAddress = '0x0000000000000000000000000000000000000000';

    async function deploy() {
        const [userAccount, fromAccount, toAccount] = await ethers.getSigners();

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
            userAccount,
            fromAccount,
            toAccount,
        };
    }

    async function getUserBalance(contract: ImplContract, userAddress: string): Promise<bigint> {
        return await contract.balanceOf(userAddress);
    }

    async function buy(contract: ImplContract, account: any, amount: number): Promise<void> {
        await contract.connect(account).buy(amount, { value: 100 });
    }

    async function approve(contract: ImplContract, owner: any, spenser: string, amount: number): Promise<void> {
        await contract.connect(owner).approve(spenser, amount);
    }

    async function transferFrom(contract: ImplContract, owner: any, from: string, to: string) {
        await contract.connect(owner).transferFrom(from, to, 5);
    }

    describe('Initial state', () => {
        it('Should set correct initial state', async () => {
            const {
                implContract,
                initialPrice,
                initialMinTokenAmount,
                initialFeePercentage
            } = await loadFixture(deploy);

            expect(await implContract.tokenPrice()).to.equal(initialPrice);
            expect(await implContract.minTokenAmount()).to.equal(initialMinTokenAmount);
            expect(await implContract.feePercentage()).to.equal(initialFeePercentage);
        });
    });

    describe('TotalSupply', () => {
       it('Should return correct total supply', async () => {
           const { implContract, userAccount } = await loadFixture(deploy);
           await buy(implContract, userAccount, 10);
           expect(await  implContract.totalSupply()).to.equal(10);
       });
    });

    describe('BalanceOf', () => {
        it('Should return correct user balance', async () => {
            const { implContract, userAccount } = await loadFixture(deploy);
            await buy(implContract, userAccount, 10);
            expect(await  implContract.balanceOf(userAccount.address)).to.equal(10);
        });
    });

    describe('Transfer', () => {
        it('Should revert', async () => {
            const { implContract, fromAccount } = await loadFixture(deploy);
            await expect(implContract.connect(fromAccount).transfer(zeroAddress, 1)).to.revertedWith('Zero address');
            await expect(implContract.transfer(fromAccount.address, 1)).to.be.revertedWith('Insufficient balance');
        });

        it('Should change user balances, emit Transfer event', async () => {
            const { implContract, fromAccount, toAccount } = await loadFixture(deploy);
            await buy(implContract, fromAccount, 10);
            await implContract.connect(fromAccount).transfer(toAccount, 5);

            expect(await implContract.balanceOf(fromAccount.address)).to.equal(5);
            expect(await implContract.balanceOf(toAccount.address)).to.equal(5);
            await expect(implContract.connect(fromAccount).transfer(toAccount, 5))
                .emit(implContract, 'Transfer')
                .withArgs(fromAccount, toAccount, 5);
        });
    });

    describe('Allowance', () => {
        it('Should return correct allowance', async () => {
            const { implContract, fromAccount, toAccount } = await loadFixture(deploy);
            await approve(implContract, fromAccount, toAccount.address, 50);
            expect(await implContract.allowances(fromAccount.address, toAccount.address)).to.equal(50);
        });
    });

    describe('Approve', () => {
        it('Should revert', async () => {
            const { implContract } = await loadFixture(deploy);
            await expect(implContract.approve(zeroAddress, 10)).to.revertedWith('Zero address');
        });

        it('Should set correct allowance and emit Approval event', async () => {
            const { implContract, fromAccount, toAccount } = await loadFixture(deploy);
            await approve(implContract, fromAccount, toAccount.address, 50);
            expect(await implContract.allowances(fromAccount.address, toAccount.address)).to.equal(50);
            await expect(implContract.connect(fromAccount).approve(toAccount.address, 1))
                .emit(implContract, 'Approval')
                .withArgs(fromAccount.address, toAccount.address, 1);
        });
    });

    describe('TransferFrom', () => {
        it('Should revert', async () => {
            const { implContract, fromAccount, toAccount } = await loadFixture(deploy);
            await expect(implContract.transferFrom(fromAccount.address, toAccount.address, 10)).to.revertedWith('Insufficient balance');
            await buy(implContract, fromAccount, 10);
            await expect(implContract.transferFrom(fromAccount.address, toAccount.address, 10)).to.revertedWith('Insufficient allowance');
        });

        it('Should change balances, change allowance, emit Transfer event', async() => {
            const { implContract, fromAccount, toAccount } = await loadFixture(deploy);
            await buy(implContract, fromAccount, 10);
            await approve(implContract, fromAccount, fromAccount.address, 5);
            await implContract.connect(fromAccount).transferFrom(fromAccount.address, toAccount.address, 1);

            expect(await implContract.balanceOf(fromAccount.address)).to.equal(9);
            expect(await implContract.balanceOf(toAccount.address)).to.equal(1);
            expect(await implContract.allowances(fromAccount.address, fromAccount.address)).to.equal(4);
            await expect(implContract.connect(fromAccount).transferFrom(fromAccount.address, toAccount.address, 1))
                .emit(implContract, 'Transfer')
                .withArgs(fromAccount.address, toAccount.address, 1);
        });
    });

    describe('StartVoting', () => {


       it('Should set new votingId', async () => {

       });

        it('Should add user to voters list', async () => {

        });

        it('Should set voting to in progress state', async () => {

        });

        it('Should set voting end time', async () => {

        });

        it('Should set new voting price', async () => {

        });

        it('Should emit voting started event', async () => {

        });

        it('Should fail if voting already in progress', async () => {

        });
    });
});
