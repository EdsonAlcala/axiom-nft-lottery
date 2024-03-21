// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Strings} from "@openzeppelin/utils/Strings.sol";

import {EarthMindNFT} from "@contracts/EarthMindNFT.sol";
import {EarthMindTicket} from "@contracts/EarthMindTicket.sol";
import {Constants} from "@constants/Constants.sol";

import "@contracts/Errors.sol";

import "@axiom-crypto/axiom-std/AxiomTest.sol";

contract EarthMindNFTTest is AxiomTest {
    using Axiom for Query;

    address internal DEPLOYER = address(0x1);
    address internal ALICE = address(0x2);
    address internal NON_OWNER = address(0x3);

    EarthMindNFT internal earthMindNFT;
    EarthMindTicket internal earthMindTicket;

    // TODO: Cambiar Input que este bien
    struct AxiomInput {
        uint256 itemId;
        uint64 blockNumberWhenNFTWasMinted;
        uint64 blockNumberWhenWinnerSelected;
        uint64 totalTickets;
        uint64 totalNFTs;
    }

    AxiomInput public input;

    bytes32 QUERY_SCHEMA;
    string QUERY_SCHEMA_PATH = "app/axiom/winner.circuit.ts";
    uint64 BLOCK_NUMBER = 4_205_938;

    address nftTicketAddress;
    uint64 callbackSourceChainId;

    function setUp() public {
        _createSelectForkAndSetupAxiom("sepolia", 5_103_100);
        _setupAccounts();

        callbackSourceChainId = uint64(block.chainid);

        vm.startPrank(DEPLOYER);

        earthMindTicket = new EarthMindTicket(Constants.EARTHMIND_TICKET_URI);
        nftTicketAddress = address(earthMindTicket);

        input = AxiomInput({
            itemId: 1,
            blockNumberWhenNFTWasMinted: 5_103_100,
            blockNumberWhenWinnerSelected: 5_103_110,
            totalTickets: 10,
            totalNFTs: 10
        });

        QUERY_SCHEMA = axiomVm.readCircuit(QUERY_SCHEMA_PATH);

        earthMindNFT = new EarthMindNFT(nftTicketAddress, axiomV2QueryAddress, callbackSourceChainId, QUERY_SCHEMA);
    }

    function test_initialProperties() public view {
        assertEq(earthMindNFT.owner(), DEPLOYER);
        assertEq(earthMindNFT.QUERY_SCHEMA(), QUERY_SCHEMA);
        assertEq(earthMindNFT.SOURCE_CHAIN_ID(), callbackSourceChainId);
        assertEq(earthMindNFT.MAX_NUMBER_OF_ITEMS(), 10);
        assertEq(earthMindNFT.MAX_NUMBER_OF_TICKETS(), 10);
        assertEq(earthMindNFT.BLOCKS_IN_FUTURE(), 10);
        assertEq(earthMindNFT.TICKET_PRICE(), 0.1 ether);
        assertEq(address(earthMindNFT.nftTicket()), nftTicketAddress);
        assertEq(earthMindNFT.isBuyingTicketsActive(), true);
        assertEq(earthMindNFT.inRaffleInProgress(), false);
    }

    function test_buyTicket() public {
        uint256 totalTickets = earthMindNFT.getTotalItemsInCollection();
        uint256 ticketPrice = earthMindNFT.TICKET_PRICE();

        // generate random buyers and put them in an array

        for (uint256 i = 0; i < totalTickets; i++) {
            earthMindNFT.buyTicket{value: ticketPrice}();
        }

        // Mint NFT 1

        // Increase block number to simulate the future 10 blocks

        // TODO: Modify blocks in the input

        // create a query into Axiom with default parameters
        Query memory newQuery = query(QUERY_SCHEMA, abi.encode(input), address(earthMindNFT));

        // send the query to Axiom
        newQuery.send();

        // prank fulfillment of the query, returning the Axiom results
        bytes32[] memory axiomResults = newQuery.prankFulfill();

        // parse Axiom results and verify length is as expected
        assertEq(axiomResults.length, 5);
        //    TODO
        // uint256 nftIdResult = uint256(axiomResults[0]);
        // uint256 blockNumberWhenNFTWasMintedResult = uint256(axiomResults[1]);
        // uint256 blockNumberWhenWinnerSelectedResult = uint256(axiomResults[2]);
        // uint256 totalTicketsResult = uint256(axiomResults[3]);
        // uint256 totalNFTsResult = uint256(axiomResults[4]);
        // uint256 nftTicketIdWinnerResult = uint256(axiomResults[5]);

        // verify the winner is the one expected
        // TODO: Execute a call to the contract to verify the winner
        // assertEq(avg, averageBalance.provenAverageBalances(blockNumber, addr));
    }

    // test buyTicket when... cases...

    // Internal functions
    function _setupAccounts() internal {
        vm.deal(DEPLOYER, 1000 ether);
        vm.deal(ALICE, 1000 ether);
        vm.deal(NON_OWNER, 1000 ether);
    }
}
