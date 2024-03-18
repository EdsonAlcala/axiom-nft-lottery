// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC1155} from "@openzeppelin/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {Counters} from "@openzeppelin/utils/Counters.sol";
import {AxiomV2Client} from "@axiom-crypto/v2-periphery/client/AxiomV2Client.sol";

import {IEarthMindTicket} from "@contracts/interfaces/IEarthMindTicket.sol";

import "./Errors.sol";

contract EarthMindNFT is ERC1155, Ownable, AxiomV2Client {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    // axiom specific
    bytes32 immutable QUERY_SCHEMA;
    uint64 immutable SOURCE_CHAIN_ID;
    uint16 public constant MAX_NUMBER_OF_ITEMS = 420;
    uint8 public constant MAX_NUMBER_OF_TICKETS = 100;
    uint8 public constant TICKET_AMOUNT_PER_BUY = 1;

    uint256 public TICKET_PRICE = 0.1 ether;
    IEarthMindTicket public immutable nftTicket;

    bool public isBuyingTicketsActive;
    bool public inRaffleInProgress;

    mapping(uint256 itemId => string metadataUri) private itemURIs;

    struct WinnerTicket {
        address winner;
        bool claimed;
    }

    mapping(uint256 itemId => WinnerTicket winnerInfo) private winners;

    event ItemAdded(uint256 indexed itemId, string metadataURI);
    event TicketBought(address indexed buyer, uint256 indexed ticketId);
    event PrizeClaimed(address indexed winner, uint256 indexed itemId);

    constructor(
        address _nftTicketAddress,
        address _axiomV2QueryAddress,
        uint64 _callbackSourceChainId,
        bytes32 _querySchema
    ) ERC1155("") AxiomV2Client(_axiomV2QueryAddress) {
        isBuyingTicketsActive = true;
        QUERY_SCHEMA = _querySchema;
        SOURCE_CHAIN_ID = _callbackSourceChainId;
        nftTicket = IEarthMindTicket(_nftTicketAddress);
    }

    // Buy Tickets functions
    function buyTicket() external payable {
        if (!isBuyingTicketsActive) {
            revert NotAvailableTickets();
        }

        uint256 totalTickets = nftTicket.getTotalTickets();

        if (totalTickets >= MAX_NUMBER_OF_TICKETS) {
            revert MaxTicketsReached();
        }

        if (msg.value < TICKET_PRICE) {
            revert InsufficientFee();
        }

        nftTicket.mintTicket(msg.sender);

        uint256 newTotalTickets = nftTicket.getTotalTickets();

        if (newTotalTickets == MAX_NUMBER_OF_TICKETS) {
            isBuyingTicketsActive = false;
        }

        emit TicketBought(msg.sender, newTotalTickets);
    }

    function claimPrize(uint256 _itemId) external {
        if (winners[_itemId].claimed) {
            revert PrizeAlreadyClaimed();
        }

        if (winners[_itemId].winner != msg.sender) {
            revert InvalidWinner();
        }

        if (winners[_itemId].winner == address(0)) {
            revert WinnerHasntBeenSelected();
        }

        winners[_itemId].claimed = true;

        _safeTransferFrom(address(this), msg.sender, _itemId, 1, "");

        emit PrizeClaimed(msg.sender, _itemId);
    }

    // Mint NFT functions
    function mintNFT(string memory _metadataURI) external onlyOwner {
        uint256 totalTickets = nftTicket.getTotalTickets();

        if (totalTickets != MAX_NUMBER_OF_TICKETS) {
            revert TicketsHasntBeenSold();
        }

        if (_tokenIds.current() >= MAX_NUMBER_OF_ITEMS) {
            revert MaxItemsReachedForCollection();
        }

        if (inRaffleInProgress) {
            revert RaffleInProgress();
        }

        // increase the item count for the collection
        _tokenIds.increment();

        uint256 itemId = _tokenIds.current();

        itemURIs[itemId] = _metadataURI;

        _mint(address(this), itemId, 1, "");

        inRaffleInProgress = true;

        // initiate the raffle

        emit ItemAdded(itemId, _metadataURI);
    }

    // Axiom functions
    function _validateAxiomV2Call(
        AxiomCallbackType, // callbackType,
        uint64 sourceChainId,
        address, // caller,
        bytes32 querySchema,
        uint256, // queryId,
        bytes calldata // extraData
    ) internal view override {
        require(sourceChainId == SOURCE_CHAIN_ID, "Source chain ID does not match");
        require(querySchema == QUERY_SCHEMA, "Invalid query schema");
    }

    function _axiomV2Callback(
        uint64, // sourceChainId,
        address, // caller,
        bytes32, // querySchema,
        uint256, // queryId,
        bytes32[] calldata axiomResults,
        bytes calldata // extraData
    ) internal override {
        // TODO: <Implement your application logic with axiomResults>
        // EXAMPLE
        // The callback from the Axiom ZK circuit proof comes out here and we can handle the results from the
        // `axiomResults` array. Values should be converted into their original types to be used properly.
        // uint256 blockNumber = uint256(axiomResults[0]);
        // address addr = address(uint160(uint256(axiomResults[1])));
        // uint256 averageBalance = uint256(axiomResults[2]);

        // You can do whatever you'd like with the results here. In this example, we just store it the value
        // directly in the contract.
        // provenAverageBalances[blockNumber][addr] = averageBalance;

        // emit AverageBalanceStored(blockNumber, addr, averageBalance);
    }

    // View functions
    function uri(uint256 _tokenId) public view override returns (string memory) {
        return itemURIs[_tokenId];
    }

    function getTotalTicketsBought() external view returns (uint256) {
        return nftTicket.getTotalTickets();
    }

    function getTotalItemsInCollection() external view returns (uint256) {
        return _tokenIds.current();
    }

    // Function to update the fee
    function setTicketPrice(uint256 _newFee) external onlyOwner {
        TICKET_PRICE = _newFee;
    }

    // Withdraw function to transfer contract balance to the owner
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent,) = owner().call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}

// inicia el proyecto
// todos los tickets se ponen a la venta
// se venden todos los tickets
// se cierra la venta de tickets
// se mintea el primero
// se elige el ganador
// se mintea el segundo
// se elige el ganador
// etc...
// tal vez permitir vender tickets en secondary market, esto requiere un ERC 20 que represente el ticket

// meter algo de tiempo para que mintee y elija ganador cada periodo de tiempo
// permitir que el owner pueda cambiar el tiempo de minteo y eleccion de ganador

// meter una flag para saber si ya se claimeo el prize
// permitir claimear muchos prizes?

//  Modify onlyOwner in mintNFT to accept an aggregated BLS signature
