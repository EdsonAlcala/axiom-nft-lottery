// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {ConfigurationMainnet} from "./Configuration.mainnet.sol";
import {ConfigurationTestnet} from "./Configuration.testnet.sol";

import {Vm} from "forge-std/Vm.sol";

library Configuration {
    using DeploymentUtils for Vm;

    struct ConfigValues {
        address axiomV2QueryAddress;
        uint64 callbackSourceChainId;
        bytes32 querySchema;
        string nftTicketURI;
    }

    function getConfiguration(Vm _vm, uint64 _networkId) external view returns (ConfigValues memory) {
        if (_networkId == Constants.ETHEREUM_MAINNET_NETWORK) {
            return ConfigurationMainnet.getConfig();
        }

        if (_networkId == Constants.ETHEREUM_SEPOLIA_NETWORK) {
            return ConfigurationTestnet.getConfig();
        }

        revert("Configuration: network not supported");
    }
}
