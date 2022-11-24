//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
    
    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';
    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol';
    import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol"; // VFR2 HAS NO POLY INFORMATIONS AVAILABLE 
    import "../contracts/SVGLib.sol";
    
contract NFTGame is ERC721{
    using SafeMath for uint256;
    using Strings for uint256;
    event statsFilled(uint256 tokenID, uint256 seed);
    uint256 public _totalSupply;
    uint256 MAX_SUPPLY;
    uint256 mintPrice;
    uint256 seamTotalSupply = 1;
    string private _baseURIextended;
    address public withdrawAddress;
    mapping (uint256=>uint256) s_RandomSeed;
    mapping (uint256 => string) private s_TokenUri;
    mapping (uint256=>Stats) s_Stats;
   
    struct Stats{
        string Race;
        uint256 Attack;
    }
    //https://blog.chain.link/how-to-get-a-random-number-on-polygon/ 
    
    constructor()
        ERC721("ERC", "ERC")
        
      
    {
   
    }
    
    
}
