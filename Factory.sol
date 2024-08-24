// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {IFactory} from "./IFactory.sol";
import {Exchange} from "./Exchange.sol";

abstract contract Factory is IFactory {

    mapping(address tokenAddress => address exchangeAddress) public token_to_Exchange;

    function createExchange(address _tokenAddress) public returns(address) {
        require(_tokenAddress != address(0), "invalid token address");
        require(token_to_Exchange[_tokenAddress] == address(0),"exchange already exists");

  Exchange exchange = new Exchange(_tokenAddress);
  token_to_Exchange[_tokenAddress] = address(exchange);

  return address(exchange);
    }

    function getExchange(address _tokenAddress) public view returns(address) {
        return token_to_Exchange[_tokenAddress];
    }
}