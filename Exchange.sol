// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {IExchange} from "./IExchange.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {

    ERC20 public immutable token;

    constructor(address _tokenAddress) ERC20("Peppyswap-V1", "Peppy-V1") {
        require(_tokenAddress != address(0), "Token address cannot be zero address");
        token = ERC20(_tokenAddress);
    }

    /**
     * @dev This function is called by the user to add liquidity to the liquidity
     * pool the user sends the equilvalent amount of the token and eth and receives
     * shares that corresponds to the user deposit to the pool
     * 
     * @param _tokenAmount the amount of the tokens the user want to add to the LP
     */
    function addLiquidity(uint256 _tokenAmount) public payable returns(uint256 shares) {
        // if the exchange contract has no ERC20 token or eth (i.e if its reserves are empty)
        // just accept the the transfer as this is the first time liquidity is being added to the 
        // exchange
        if (getReserve() == 0) {
            token.transferFrom(msg.sender, address(this), _tokenAmount);
        } else {
        // else if the exchange reserves are not empty ensure that the price ratio does not 
        // change with added liquidity.
            // ethReserve is the amount of eth owned by the exchange contract before
            // it is given by address(this).balance - msg.value because we have to subtract
            // the eth sent to this function call.
            uint256 ethReserve = address(this).balance - msg.value;
            // get the total ERC20 token owned by the exchange contract
            uint256 tokenReserve = getReserve();
            // ensure that price is maintained when adding liquidity therefore ratio of token 
            // to eth in reserves should be equal to ratio of token to eth to be added
            // tokenReserve / ethReserve = tokenAdded / ethAdded
            // cross multiplying we have:
            // tokenReserve * ethAdded =  ethReserve * tokenAdded
            require(tokenReserve * msg.value == ethReserve * _tokenAmount, "Invalid Tokens amount");

            // send the ERC20 tokens from the sender to the exchange
            token.transferFrom(msg.sender, address(this), _tokenAmount);

        }
    }

    /**
     * @dev This returns the amount of token in the liquidity pool
     */
    function getReserve() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @dev This function returns the price of the token relative to eth or price of eth relative 
     * to the token depending of which is used as the inputReserve and outputReserve.
     * 
     * @param inputReserve This could be either eth or the token. If you want price relative to eth
     * inputReserve would be the token amount if you want price relative to the token inputReserve 
     * would be amount of eth.
     * @param outputReserve This could be either eth or the token. If you want price relative to eth
     * outputReserve would be the amount of eth if you want price relative to the token outputReserve 
     * would be the token amount.
     */
    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns (uint256) {
        // ensure the exchange has eth and the ERC20 tokens
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        // calculate price
        return inputReserve / outputReserve;
    }

    /**
     * @dev This function calculates the amount of output tokens(tokens in this statement could be eth or the ERC20
     * token) that is to sent to the swapper for inputAmount amount of  input tokens. The formular is given by 
     * dy = (y * dx) / (x + dx) where:
     * dy: the amount of output tokens to be sent to the swapper
     * y: the total amount of output tokens owned by the exchange
     * dx: the amount of input token sent by the swapper to the exchange
     * x: the total amount of the input tokens owned by the exchange 
     * 
     * @param inputAmount This is the amount of the input tokens i.e the tokens(token in this statement could be eth
     *  or the ERC20 token) sent to the exchange contract
     * @param inputReserve This is the total amount of the input token(token in this statement could be eth or the 
     * ERC20 token) owned by the contract
     * @param outputReserve This is the total amount of the output token(token in this statement could be eth or the 
     * ERC20 token) owned by the contract
     */
    function getAmount(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) private pure returns (uint256) {
        // ensure the exchange has eth and the ERC20 tokens
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        // perform the calculation for dy the output amount
        return (inputAmount * outputReserve) / (inputReserve + inputAmount);
    }

    /**
     * @dev This function is a view function that calculates the amount of the ERC20 token a 
     * swapper expects to receive if the swapper swaps _ethSold amount of eth
     * @param _ethSold The amount of eth to be swap
     */
    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        // ensure eth amount is not zero
        require(_ethSold > 0, "ethSold is too small");
        // get the total amount of ERC20 tokens owned by the exchange contract
        uint256 tokenReserve = getReserve();
        // calculate the amount of token the user should expect to receive in return
        return getAmount(_ethSold, address(this).balance, tokenReserve);
    }

    /**
     * @dev This function is a view function that calculates the amount of eth a swapper expects
     * to receive if the swapper swaps _tokenSold amount of the ERC20 token
     * @param _tokenSold The amount of eth to be swap
     */
    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        // ensure token amount is not zero
        require(_tokenSold > 0, "tokenSold is too small");
        // get the total amount of ERC20 tokens owned by the exchange contract
        uint256 tokenReserve = getReserve();
        // calculate the amount of eth user should expect to receive in return 
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    /**
     * @dev This function swaps eth to the ERC20 token
     * 
     * @param _minTokens The minimum amount the ERC20 token the user expects to receive
     * after the eth to token swap.
     */
    function ethToTokenSwap(uint256 _minTokens) public payable {
        // get the total number of ERC20 token owned by this contract
        uint256 tokenReserve = getReserve();
        // solve for the amount of ERC20 tokens to be sent to user
        uint256 tokensBought = getAmount(msg.value, address(this).balance - msg.value, tokenReserve);

        // ensure that token amount calculated is greater than or equal to minimum amount of tokens specified
        require(tokensBought >= _minTokens, "insufficient output amount");
        // transfer the said tokens to the user
        token.transfer(msg.sender, tokensBought);
    }

    /**
     * This function swaps the ERC20 token to ether
     * 
     * @param _tokensSold The amount of ERC20 token the swapper wants to swap for eth
     * @param _minEth The minimum amount of eth the swapper expects to receive after the 
     * eth to token reserve
     */
    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) public {
        // get the total number of ERC20 token owned by this contract
        uint256 tokenReserve = getReserve();
        // solve for the amount of eth to be sent to user
        uint256 ethBought = getAmount(_tokensSold, tokenReserve, address(this).balance);

        // ensure that eth amount calculated is greater than or equal to minimum amount of eth specified
        require(ethBought >= _minEth, "insufficient output amount");
        // transfer the ERC20 tokens from user to the contract
        token.transferFrom(msg.sender, address(this), _tokensSold);
        // transfer eth to the user
        payable(msg.sender).transfer(ethBought);
    }


}