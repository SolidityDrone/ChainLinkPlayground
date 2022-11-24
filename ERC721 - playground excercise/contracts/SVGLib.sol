// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;


library SVGLib {
    string internal  constant svg_Header = 
        '<svg id="elfbOpLEU5j1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 400 425" shape-rendering="geometricPrecision" text-rendering="geometricPrecision">';
    string internal constant svg_Tail = '</svg>';
    string internal constant svg_Type_1 =
        '<rect stroke="#000" id="svg_10" height="400" width="402" y="-0.00001" x="0.00001" fill="#1fff"/>';   
    string internal constant svg_Type_2 =
        '<rect stroke="#000" id="svg_10" height="400" width="402" y="-0.00001" x="0.00001" fill="#0fffff"/>';   
    string internal constant svg_Type_3 =
        '<rect stroke="#000" id="svg_10" height="400" width="402" y="-0.00001" x="0.00001" fill="#ff0000"/>';    
   
    function assembleString(uint256 _type) internal pure returns (bytes memory svg_Result){
            
            string memory svg_Type;
            if (_type == 1){
                svg_Type = svg_Type_1;
            }
             if (_type == 2){
                svg_Type = svg_Type_2;
            }
             if (_type == 3){
                svg_Type = svg_Type_3;
            }
            
            return bytes(string(abi.encodePacked(SVGLib.svg_Header, svg_Type, SVGLib.svg_Tail))); 
      
        
    }
}
