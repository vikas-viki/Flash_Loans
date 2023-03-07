// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "./Flashloan.sol";
import "./Token.sol";

contract FlashloanReciever {
    Flashloan private pool;
    address private owner;

    event LoanRecived(address _tokenAddress, uint256 _amt);

    constructor(address _poolAddress) {
        pool = Flashloan(_poolAddress);
        owner = msg.sender;
    }

    function recieveTokens(address _tokenAddress, uint256 _amt) external {
        require(msg.sender == address(pool), "only loan provider can call this");

        // Do stuff with funds after recieving
        console.log("recieveTokens:", _tokenAddress, _amt);

        // check if we got the amount.
        require(Token(_tokenAddress).balanceOf(address(this)) == _amt, "error in getting flashloan");
        emit LoanRecived(_tokenAddress, _amt);
        console.log("flashLoanBalance: ", Token(_tokenAddress).balanceOf(address(this)));

        // Pay back
        require(Token(_tokenAddress).transfer(msg.sender, _amt), "Transfer back of tokens failed");
    }

    function executeFlashloan(uint _amt) external {
        require(msg.sender == owner, "Only owner can borrow amount");
        pool.flashLoan(_amt);
    }
}


// events, interfaces