// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

interface IExchange {

    function addLiquidity(uint256 _tokenAmount) external payable returns(uint256 shares);

    function getReserve() external view returns (uint256);

    function getPrice(uint256 inputReserve, uint256 outputReserve) external pure returns (uint256);

    function ethToTokenSwap(uint256 _minTokens) external payable ;

    function tokenToEthSwap(uint256 _tokensSold, uint256 _minEth) external;

    function removeLiquidity(uint256 _shares) external returns (uint256, uint256);
    
}