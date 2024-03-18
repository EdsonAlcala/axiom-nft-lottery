// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindTicket} from "@contracts/EarthMindTicket.sol";

import "@contracts/Errors.sol";

import {Test} from "forge-std/Test.sol";

contract EarthMindTicketTest is Test {
    address internal DEPLOYER = address(0x1);
    address internal ALICE = address(0x2);
    address internal NON_OWNER = address(0x3);

    EarthMindTicket internal earthMindTicket;

    string internal constant TICKET_URI = "ipfs://QmdiZADNgiJwi6i6qQ3QwWMA6iq77dbHwDof8ukNPaAZDL";

    function setUp() public {
        _setupAccounts();

        vm.prank(DEPLOYER);

        earthMindTicket = new EarthMindTicket(TICKET_URI);
    }

    function test_initial_properties() public view {
        assertEq(earthMindTicket.owner(), DEPLOYER);
        assertEq(earthMindTicket.name(), "EarthMindTicket");
        assertEq(earthMindTicket.symbol(), "EMTicket");
    }

    function test_mint() public {
        vm.startPrank(DEPLOYER);

        earthMindTicket.mintTicket(ALICE);

        assertEq(earthMindTicket.balanceOf(ALICE), 1);
        assertEq(earthMindTicket.ownerOf(1), ALICE);
        assertEq(earthMindTicket.tokenURI(1), TICKET_URI);
        assertEq(earthMindTicket.getTotalTickets(), 1);
    }

    function test_mint_when_no_owner_reverts() public {
        vm.startPrank(NON_OWNER);

        vm.expectRevert("Ownable: caller is not the owner");
        earthMindTicket.mintTicket(ALICE);
    }

    // Internal functions
    function _setupAccounts() internal {
        vm.deal(DEPLOYER, 1000 ether);
        vm.deal(ALICE, 1000 ether);
        vm.deal(NON_OWNER, 1000 ether);
    }
}
