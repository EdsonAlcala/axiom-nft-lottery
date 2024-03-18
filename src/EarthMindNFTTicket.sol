// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract EarthMindNFTTicket is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _ticketIds;
    string private _commonURI;

    constructor(string memory commonURI) ERC721("TicketNFT", "TICKET") {
        _commonURI = commonURI;
    }

    function mintTicket(address to) public onlyOwner {
        _ticketIds.increment();
        uint256 newItemId = _ticketIds.current();
        _mint(to, newItemId);
    }

    function _baseURI() internal view override returns (string memory) {
        return _commonURI;
    }
}
