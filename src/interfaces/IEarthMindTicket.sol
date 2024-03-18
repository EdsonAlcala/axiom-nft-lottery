// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC721} from "@openzeppelin/token/ERC721/IERC721.sol";

interface IEarthMindTicket is IERC721 {
    function mintTicket(address to) external;

    function getTotalTickets() external view returns (uint256);
}
