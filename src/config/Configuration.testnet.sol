// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {Configuration} from "./Configuration.sol";

library ConfigurationTestnet {
    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues({
            callbackSourceChainId: Constants.ETHEREUM_SEPOLIA_NETWORK,
            querySchema: Constants.EARTHMIND_QUERY_SCHEMA,
            axiomV2QueryAddress: Constants.SEPOLIA_AXIOM_V2_QUERY_MOCK_ADDRESS,
            nftTicketURI: Constants.EARTHMIND_TICKET_URI
        });
    }
}
