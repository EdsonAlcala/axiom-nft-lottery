// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindTicket} from "@contracts/EarthMindTicket.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {DeployerUtils} from "@utils/DeployerUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./BaseScript.s.sol";
import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract TransferOwnershipScript is BaseScript {
    using DeployerUtils for Vm;
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Transferring EarthMindTicket ownership contract");
        deployer = vm.loadDeployerAddress();

        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        address ticketAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_TICKET);
        address earthMindNFTAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_NFT);

        EarthMindTicket earthMindTicket = EarthMindTicket(ticketAddress);
        earthMindTicket.transferOwnership(earthMindNFTAddress);

        assert(earthMindTicket.owner() == earthMindNFTAddress);
    }
}
