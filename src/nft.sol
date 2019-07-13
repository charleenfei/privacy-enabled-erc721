// Copyright (C) 2019 lucasvo

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.4.24;

import { ERC721Enumerable } from "./openzeppelin-solidity/token/ERC721/ERC721Enumerable.sol";
import { ERC721Metadata } from "./openzeppelin-solidity/token/ERC721/ERC721Metadata.sol";

contract AnchorLike {
    function getAnchorById(uint) public returns (uint, bytes32, uint32);
}

contract NFT is ERC721Enumerable, ERC721Metadata {
    // --- Data ---
    AnchorLike public           anchors;
    bytes32 public              ratings; 
    string public               uri_prefix; 

    string public uri;
    
    constructor (string memory name, string memory symbol, address anchors_) ERC721Enumerable() ERC721Metadata(name, symbol) public {
        anchors = AnchorLike(anchors_);
    }

    // --- Utils ---
    function concat(bytes32 b1, bytes32 b2) pure internal returns (bytes memory)
    {
        bytes memory result = new bytes(64);
        assembly {
            mstore(add(result, 32), b1)
            mstore(add(result, 64), b2)
        }
        return result;
    }
    
    function uint2str(uint i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    // --- NFT ---
    function checkAnchor(uint anchor, bytes32 droot, bytes32 sigs) public returns (bool) {
        bytes32 root;
        (, root, ) = anchors.getAnchorById(anchor);
        return root == sha256(concat(droot, sigs));
    }

    // unpack takes one bytes32 argument and turns it into two uint256 to make it fit into a field element
    function unpack(bytes32 x) public returns (uint y, uint z) {
        bytes32 a = bytes32(x);
        bytes32 b = (a>> 128);
        bytes32 c = ((a<< 128)>> 128);
        return (uint(b), uint(c));
    }
}
