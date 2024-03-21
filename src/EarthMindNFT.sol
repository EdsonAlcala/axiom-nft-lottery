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
    bytes32 public immutable QUERY_SCHEMA;
    uint64 public immutable SOURCE_CHAIN_ID;

    uint16 public constant MAX_NUMBER_OF_ITEMS = 10;
    uint16 public constant MAX_NUMBER_OF_TICKETS = 10;
    uint8 public constant TICKET_AMOUNT_PER_BUY = 1;
    uint8 public constant BLOCKS_IN_FUTURE = 10;

    uint256 public TICKET_PRICE = 0.1 ether;
    IEarthMindTicket public immutable nftTicket;

    bool public isBuyingTicketsActive;
    bool public inRaffleInProgress;

    mapping(uint256 nftItemId => string metadataUri) private itemURIs;

    struct WinnerTicket {
        uint256 ticketId;
        address winner;
        uint256 blockNumberWhenNFTWasMinted;
        uint256 blockNumberWhenWinnerSelected;
    }

    mapping(uint256 nftItemId => WinnerTicket winnerInfo) private winners;
    mapping(uint256 nftItemId => uint256 blockNumber) private blockWhenWinnerWillBeChosen;

    event NFTAdded(
        uint256 indexed nftItemId, string metadataURI, uint256 blockNumber, uint256 blockWhenWinnerWillBeChosen
    );
    event TicketBought(address indexed buyer, uint256 indexed ticketId);
    event WinnerAnnounced(address indexed winner, uint256 indexed itemId);

    constructor(
        address _nftTicketAddress,
        address _axiomV2QueryAddress,
        uint64 _callbackSourceChainId,
        bytes32 _querySchema
    ) ERC1155("") AxiomV2Client(_axiomV2QueryAddress) {
        nftTicket = IEarthMindTicket(_nftTicketAddress);
        QUERY_SCHEMA = _querySchema;
        SOURCE_CHAIN_ID = _callbackSourceChainId;
        isBuyingTicketsActive = true;
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

        blockWhenWinnerWillBeChosen[itemId] = block.number + BLOCKS_IN_FUTURE;

        emit NFTAdded(itemId, _metadataURI, block.number, block.number + BLOCKS_IN_FUTURE);
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
        if (sourceChainId != SOURCE_CHAIN_ID) {
            revert InvalidSourceChainId();
        }

        if (querySchema != QUERY_SCHEMA) {
            revert InvalidQuerySchema();
        }
    }

    function _axiomV2Callback(
        uint64, // sourceChainId,
        address, // caller,
        bytes32, // querySchema,
        uint256, // queryId,
        bytes32[] calldata axiomResults,
        bytes calldata // extraData
    ) internal override {
        uint256 nftId = uint256(axiomResults[0]);
        uint256 blockNumberWhenNFTWasMinted = uint256(axiomResults[1]);
        uint256 blockNumberWhenWinnerSelected = uint256(axiomResults[2]);
        uint256 totalTickets = uint256(axiomResults[3]);
        uint256 totalNFTs = uint256(axiomResults[4]);
        uint256 nftTicketIdWinner = uint256(axiomResults[5]);

        if (nftId > _tokenIds.current()) {
            revert InvalidTokenId();
        }

        if (totalTickets != nftTicket.getTotalTickets()) {
            revert InvalidTotalTickets();
        }

        if (totalNFTs != _tokenIds.current()) {
            revert InvalidTotalNFTs();
        }

        uint256 blockNumberWhenWinnerWasChosen = blockWhenWinnerWillBeChosen[nftId];

        if (blockNumberWhenNFTWasMinted != blockNumberWhenWinnerWasChosen - BLOCKS_IN_FUTURE) {
            revert InvalidBlockNumber();
        }

        if (blockNumberWhenWinnerSelected != blockNumberWhenWinnerWasChosen) {
            revert InvalidBlockNumber();
        }

        if (block.number < blockNumberWhenWinnerWasChosen) {
            revert InvalidBlockNumber();
        }

        address nftWinnerAddress = nftTicket.ownerOf(nftTicketIdWinner);

        if (nftWinnerAddress == address(0)) {
            revert InvalidWinner();
        }

        winners[nftId] = WinnerTicket({
            ticketId: nftTicketIdWinner,
            winner: nftWinnerAddress,
            blockNumberWhenNFTWasMinted: blockNumberWhenNFTWasMinted,
            blockNumberWhenWinnerSelected: blockNumberWhenWinnerSelected
        });

        inRaffleInProgress = false;

        _safeTransferFrom(address(this), nftWinnerAddress, nftId, 1, "");

        emit WinnerAnnounced(nftWinnerAddress, nftId);
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
