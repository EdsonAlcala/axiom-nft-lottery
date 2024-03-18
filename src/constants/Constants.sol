// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Constants {
    uint64 public constant ETHEREUM_MAINNET_NETWORK = 1;
    uint64 public constant ETHEREUM_SEPOLIA_NETWORK = 11155111;
    uint64 public constant LOCAL_NETWORK = 31337;
    uint64 public constant LOCAL_TEST_NETWORK = 3137;

    string public constant EARTHMIND_TICKET = "EarthMindTicket";
    string public constant EARTHMIND_NFT = "EarthMindNFT";
    string public constant EARTHMIND_TICKET_URI = "ipfs://QmdiZADNgiJwi6i6qQ3QwWMA6iq77dbHwDof8ukNPaAZDL";

    address public constant AXIOM_V2_QUERY_ADDRESS = 0x83c8c0B395850bA55c830451Cfaca4F2A667a983;
    address public constant SEPOLIA_AXIOM_V2_QUERY_MOCK_ADDRESS = 0x83c8c0B395850bA55c830451Cfaca4F2A667a983;
}
