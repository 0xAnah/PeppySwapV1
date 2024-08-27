// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {IFactory} from "./IFactory.sol";
import {Exchange} from "./Exchange.sol";

contract Factory is IFactory {

    mapping(address tokenAddress => address exchangeAddress) public token_to_Exchange;

    function createExchange(address _tokenAddress) public returns(address) {
        // ensure token address is not zero address
        require(_tokenAddress != address(0), "invalid token address");
        // ensure that this token exchange does not exist in this registry
        require(token_to_Exchange[_tokenAddress] == address(0),"exchange already exists");

        // create the token ERC20 exchange
        Exchange exchange = new Exchange(_tokenAddress);
        // add tthe exchange address to list 
        token_to_Exchange[_tokenAddress] = address(exchange);

        return address(exchange);
    }

    function getExchange(address _tokenAddress) public view returns(address) {
        return token_to_Exchange[_tokenAddress];
    }
}