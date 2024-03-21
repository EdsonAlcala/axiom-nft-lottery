// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {Configuration} from "./Configuration.sol";

library ConfigurationMainnet {
    function getConfig() external pure returns (Configuration.ConfigValues memory) {
        return Configuration.ConfigValues({
            callbackSourceChainId: Constants.ETHEREUM_MAINNET_NETWORK,
            querySchema: Constants.EARTHMIND_QUERY_SCHEMA,
            axiomV2QueryAddress: Constants.AXIOM_V2_QUERY_ADDRESS,
            nftTicketURI: Constants.EARTHMIND_TICKET_URI
        });
    }
}
