// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindTicket} from "@contracts/EarthMindTicket.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {DeployerUtils} from "@utils/DeployerUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./BaseScript.s.sol";
import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract EarthMindDeployTicketScript is BaseScript {
    using DeployerUtils for Vm;
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Deploying EarthMindTicket contract");
        deployer = vm.loadDeployerAddress();

        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        string memory ticketURI = config.nftTicketURI;
        console2.log("Ticket URI");
        console2.logString(ticketURI);

        EarthMindTicket earthMindTicket = new EarthMindTicket(ticketURI);

        console2.log("EarthMindTicket Address");
        console2.logAddress(address(earthMindTicket));

        vm.saveDeploymentAddress(Constants.EARTHMIND_TICKET, address(earthMindTicket));
    }
}
