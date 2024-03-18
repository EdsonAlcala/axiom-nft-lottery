// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";

import {ConfigurationLocal} from "./Configuration.local.sol";
import {ConfigurationMainnet} from "./Configuration.mainnet.sol";
import {ConfigurationTestnet} from "./Configuration.testnet.sol";

library Configuration {
    struct ConfigValues {
        address axiomV2QueryAddress;
        uint64 callbackSourceChainId;
        bytes32 querySchema;
        string nftTicketURI;
    }

    function load(uint64 _networkId) external pure returns (ConfigValues memory) {
        if (_networkId == Constants.ETHEREUM_MAINNET_NETWORK) {
            return ConfigurationMainnet.getConfig();
        }

        if (_networkId == Constants.ETHEREUM_SEPOLIA_NETWORK) {
            return ConfigurationTestnet.getConfig();
        }

        if (_networkId == Constants.LOCAL_NETWORK) {
            return ConfigurationLocal.getConfig();
        }

        revert("Configuration: network not supported");
    }
}
