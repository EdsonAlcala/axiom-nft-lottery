// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/utils/Counters.sol";
import "@openzeppelin/access/Ownable.sol";

contract EarthMindTicket is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _ticketIds;
    string private _commonURI;

    constructor(string memory commonURI) ERC721("EarthMindTicket", "EMTicket") {
        _commonURI = commonURI;
    }

    function mintTicket(address to) external onlyOwner {
        _ticketIds.increment();
        uint256 newItemId = _ticketIds.current();
        _safeMint(to, newItemId);
    }

    function getTotalTickets() external view returns (uint256) {
        return _ticketIds.current();
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return _commonURI;
    }
}
