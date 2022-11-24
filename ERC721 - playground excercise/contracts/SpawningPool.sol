//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
    
/*
Client address mints with lazy methods 
1 Mint = Zerg
Zerg go to missions
Mission gives a given amount of $VGas
*/




    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';
    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';
    import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol';
    import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol"; // VFR2 HAS NO POLY INFORMATIONS AVAILABLE 
    import "../contracts/SVGLib.sol";
    
contract SpawningPool is ERC721, VRFConsumerBase {
    using SafeMath for uint256;
    using Strings for uint256;
    event statsFilled(uint256 tokenID, uint256 seed);
    uint256 public _totalSupply;
    uint256 MAX_SUPPLY;
    uint256 mintPrice;
    uint256 seamTotalSupply = 1;
    uint256 orbCount = 1;
    string private _baseURIextended;
    mapping (uint256=>uint256) s_RankPoints;
    mapping (uint256=>uint256) s_RankLevel;
    mapping (uint256=>uint256) s_RandomSeed;
    mapping (uint256 => string) private s_TokenUri;
    mapping (uint256=>Stats) s_Stats;
    
    struct Stats{
        uint256 Background;
        uint256 Type;
        uint256 Head;
        uint256 Body;
        uint256 Eyes;
        
    }
    //https://blog.chain.link/how-to-get-a-random-number-on-polygon/ <-- contains infos to get vfr calls via keyHash 
    uint256[] rankTresholds = [10, 20, 30, 40, 50, 60]; 
    string[] s_rankNames = ["a", "b", "c", "d", "e", "f"];


    constructor()
        ERC721("ERC", "ERC")
        VRFConsumerBase(
        0x8C7382F9D8f56b33781fE506E897a4F1e2d17255,
        0x326C977E6efc84E512bB9C30f76E30c160eD06FB
        ) 
    {
    _safeMint(msg.sender, _totalSupply +1); ////DELETE//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
    fee = 100000000000000; 
    _totalSupply = 0;
    MAX_SUPPLY = 2000;
   
    mintPrice = 1 wei; 
    }
    bytes32 internal keyHash;
    uint256 internal fee;
    
function CharacterStats(uint256 _characterID) public view returns (uint256 background, uint256 typeid, uint256 head, uint256 body, uint256 eyes, string memory rank){
    return (
    s_Stats[_characterID].Background,
    s_Stats[_characterID].Type,
    s_Stats[_characterID].Head,
    s_Stats[_characterID].Body, 
    s_Stats[_characterID].Eyes, 
    s_rankNames[s_RankLevel[_characterID]]
    );
}  

function getLevel(uint256 _characterID) external view  returns (uint256 rank){
    return s_RankLevel[_characterID];
}





mapping (bytes32 => uint8) s_RequestType;
uint256 public randomResult;

function getRandomNumber() internal returns (bytes32 requestId) {
    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
    return requestRandomness(keyHash, fee);
}
function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
    uint256 _randomnessType = s_RequestType[requestId];
    if (_randomnessType == 0)
    {
        fulfillMint(randomness);
        randomResult = randomness;
    }
    else if (_randomnessType == 1)
    {
       if (randomResult % 1000 == 404){
           orbMint();
       }
       
    }
}



function orbMint() internal {
    if (orbCount < 10){
        _safeMint(msg.sender, 2000+orbCount );
    } 
    
}



function _mint() external payable
    {   
        require(msg.value == mintPrice, "Need to send 0.08 ether"); 
        require(_totalSupply < MAX_SUPPLY, "Supply cap was met, unable to procede with mint");
        _safeMint(msg.sender, _totalSupply +1);
        _totalSupply += 1;
        getRandomNumber(); 
    }

function fulfillMint(uint256 randomness) internal
    {
        s_RandomSeed[seamTotalSupply] =  (randomness % 4194303) + 1; 
        uint256[] memory expandedValues;
        expandedValues = new uint256[](6);
        for (uint256 i = 0; i < 5; i++) 
        { 
            expandedValues[i] = uint256(keccak256(abi.encode((randomness % 4194303) +1, i)));
            if (i == 0 || i == 1){
            expandedValues[i] %=2; 
            } else {
            expandedValues[i] %=5; 
            }
            
            
             
        }
        s_Stats[seamTotalSupply].Background = expandedValues[0] + 1;
        s_Stats[seamTotalSupply].Type = expandedValues[1] + 1;
        s_Stats[seamTotalSupply].Head = expandedValues[2] + 1;
        s_Stats[seamTotalSupply].Body = expandedValues[3] + 1;
        s_Stats[seamTotalSupply].Eyes = expandedValues[4] + 1;
        
        seamTotalSupply +=1;
    }
   

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "My721Token #', tokenId.toString(), ',"',
                '"image": "data:image/svg+xml;base64,', Base64.encode(SVGLib.assembleString(s_Stats[tokenId].Background)),'"',
                
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
    
    //RANK 
    function getRankedScore(uint256 _tokenID) public view returns (uint256 RankPoints){
        return s_RankPoints[_tokenID];
    }


    function getRankLevel(uint256 _tokenID) public view returns (uint256 RankLevel){
        return s_RankLevel[_tokenID];
    }
    
 
    

  
   
    function stake(uint256 _tokenID, address missioncontract) public{
        approve(address(this), _tokenID);
        this.safeTransferFrom(msg.sender, missioncontract, _tokenID);
    }


      function assignPoints(uint256 _tokenID, uint256 _amount) external returns (bool success){
        //require ## only staking contract can call this function 
        s_RankPoints[_tokenID] += _amount;
        return checkLvlUp(_tokenID);
    }
       
    function checkLvlUp(uint256 _tokenID) internal returns (bool success){
        uint256 ranklevel = s_RankLevel[_tokenID];
        uint256 rankpoints =  s_RankPoints[_tokenID];
        if (rankpoints > rankTresholds[ranklevel]){
            s_RankLevel[_tokenID] += 1;
            return (true);
        } else {
            return (false);
        }
    }




}
  