// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Configuration} from "@config/Configuration.sol";
import {DeployerUtils} from "@utils/DeployerUtils.sol";

import {Script} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";

contract BaseScript is Script {
    using DeployerUtils for Vm;

    Configuration.ConfigValues internal config;
    address internal deployer;

    constructor() {
        string memory networkId = vm.envString("NETWORK_ID");

        uint64 networkIdInt = uint64(vm.parseUint(networkId));

        config = Configuration.load(networkIdInt);

        deployer = vm.loadDeployerAddress();
    }
}
