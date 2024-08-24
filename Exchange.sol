// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

import {IExchange} from "./IExchange.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

 abstract contract Exchange is IExchange, ERC20 {

    ERC20 public immutable token;


    constructor(address _tokenAddress) {
        token = ERC20(_tokenAddress);
    }
}