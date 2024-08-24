// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.22;

interface IFactory {
    /**
     * @dev the createExchange function allows to create and deploy an exchange by 
     * simply taking a token address
     * 
     * @param _tokenAddress address of the ERC20 token whose exchange is to be
     * created
     */
    function createExchange(address _tokenAddress) external returns(address);

    /**
     * @dev  this function allow us to query the registry via an interface from another contract
     * 
     * @param _tokenAddress address of the ERC20 token whose exchange address is to 
     * be returned
     */
    function getExchange(address _tokenAddress) external view returns (address);


}