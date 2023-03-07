// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
// https://github.com/OpenZeppelin/damn-vulnerable-defi
import "./Token.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReciver{
    function recieveTokens(address tokenAddress, uint256 amount) external;
}

contract Flashloan is ReentrancyGuard{
    using SafeMath for uint256;

    Token public token;
    uint256 public poolBalance;

    constructor(address _tokenAddress){
        token = Token(_tokenAddress);
    }

    function depositTokens(uint256 _amt) external nonReentrant{
        require(_amt > 0, "Must send atleast 1 token.");
        token.transferFrom(msg.sender, address(this), _amt);
        poolBalance = poolBalance.add(_amt);
    }

    function flashLoan(uint256 _borrowAmt) external nonReentrant{

        require(_borrowAmt > 0, "Must borrow token more then 0");
        // getting balance of this contract.
        uint256 balanceBefore = token.balanceOf(address(this));
        
        // check if previous pool balance is equal to current checked balance.
        assert(poolBalance == balanceBefore);

        // check if the borrowed amount is greater than the balance.
        require(balanceBefore >= _borrowAmt , "Not enough balance in the pool");

        // Send tokens to reciever
        token.transfer(msg.sender, _borrowAmt);

        
        IReciver(msg.sender).recieveTokens(address(token), _borrowAmt);

        //get paid back.
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter == balanceBefore, "Flashloan didn't paid back");
        
    }
}