const { ethers } = require('hardhat');
const { expect } = require("chai");
const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether');
}

const ether = tokens;

describe('flashloan', () => {
    var token;
    var flashLoan;
    var flashLoanReciever;
    var deployer;
    beforeEach(async() => {
        let transaction;
        const accounts = await ethers.getSigners();
        deployer = accounts[0];

        // Load contracts
        const FlashLoan = await ethers.getContractFactory('Flashloan');
        const FlashLoanReceiver = await ethers.getContractFactory('FlashloanReciever');
        const Token = await ethers.getContractFactory('Token');

        // Deploy token
        token = await Token.deploy('WebDevSolutions', 'WDS', tokens(1000000));
        
        // Deploy flashloan
        flashLoan = await FlashLoan.deploy(token.address);

        // Deploy flashLoanReciever.
        flashLoanReciever = await FlashLoanReceiver.deploy(flashLoan.address);

        // Approve flashloan for transaction
        transaction = await token.connect(deployer).approve(flashLoan.address ,tokens(1000000));
        await transaction.wait();
        
        // Make transaction
        transaction = await flashLoan.connect(deployer).depositTokens(tokens(1000000));
        await transaction.wait();
    })

    describe('deployment', () => {
        it('works', async () => {
            expect(await token.balanceOf(flashLoan.address)).to.equal(tokens(1000000));
        })
    })

    describe('borrowing funds', () => {
        it('borrows funds from the pool', async () => {
            let amount = tokens(100);
            // calling executeFlashloans function to make a call to flashloan pool to borrowfunds, after pool sending the money,
            // it ensures that the function 'recieveTokens' is called to get it money back/it calls the 'recieveTokens' function.
            let transaction = await flashLoanReciever.connect(deployer).executeFlashloan(amount);
            await transaction.wait();

            await expect(transaction).to.emit(flashLoanReciever, 'LoanRecived').withArgs(token.address, amount);

        })
    })
})
