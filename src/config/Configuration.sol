// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Constants} from "@constants/Constants.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";

import {ConfigurationLocal} from "./Configuration.local.sol";
import {ConfigurationMainnet} from "./Configuration.mainnet.sol";
import {ConfigurationTestnet} from "./Configuration.testnet.sol";
import {ConfigurationTest} from "./Configuration.test.sol";

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

        if (_networkId == Constants.LOCAL_NETWORK) {
            return ConfigurationLocal.getConfig();
        }

        if (_networkId == Constants.LOCAL_TEST_NETWORK) {
            return ConfigurationTest.getConfig();
        }

        revert("Configuration: network not supported");
    }
}
