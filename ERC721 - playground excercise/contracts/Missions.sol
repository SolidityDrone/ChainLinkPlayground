// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
interface INFTGame {
    function getLevel(uint256) external view returns (uint256);
    function assignPoints(uint256 _tokenID, uint256 _amount) external returns (bool);
} 
contract Staking is ReentrancyGuard {
    IERC20 public vGas;
    IERC721 public parentNFT;
    INFTGame public parentNftFunctions;
    address public parentNFTAddress;

    mapping (uint256=>address) s_stakers;
    mapping (uint256=>uint256) s_missionTimers;

    constructor(address _nftContract, address _tokenContract)
 
     {  
        parentNFT = IERC721(_nftContract);
        parentNftFunctions = INFTGame(_nftContract);
        vGas = IERC20(_tokenContract);
        parentNFTAddress = _nftContract;
        
    }

     
    function getStakes(uint256 _tokenID) public view returns (address add, uint256 time)
    {
        return (s_stakers[_tokenID], s_missionTimers[_tokenID]);
    }
    
    function unstake(uint256 _tokenID) public  returns (uint256 tokenID, address to, uint256 amountClaimed)
    {   
        require(msg.sender == s_stakers[_tokenID], "Not allowed to claim ownership");
        require(block.timestamp > s_missionTimers[_tokenID], "Too early to claim ownership, you can call emergency function");
        uint256 amount = ((parentNftFunctions.getLevel(_tokenID)+1)*5);
        parentNftFunctions.assignPoints(_tokenID, amount);
        parentNFT.safeTransferFrom(address(this), msg.sender, _tokenID);
        vGas.transfer(msg.sender, amount);
 
        s_stakers[_tokenID] = address(0);
        return (_tokenID, msg.sender, s_missionTimers[_tokenID]);
    }

    function emergencyUnstake(uint256 _tokenID) public returns (uint256 tokenID, address to)
    {
        require(msg.sender == s_stakers[_tokenID], "Not allowed to claim ownership");
        
        parentNFT.safeTransferFrom(address(this), msg.sender, _tokenID);
        s_stakers[_tokenID] = address(0);
        return (_tokenID, msg.sender);

    }



    
    function onERC721Received(address _operator, address _sender, uint256 _tokenID, bytes memory) public virtual returns (bytes4) 
    {
        if (_operator == parentNFTAddress)
        {
        s_stakers[_tokenID] = _sender;
        s_missionTimers[_tokenID] = block.timestamp + 10 seconds;
        }
        
        return this.onERC721Received.selector;
    }
    

    
 

   
 

    

}