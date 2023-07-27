//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {MultiSig} from "../src/MultiSig.sol";
import {MultiSigScript} from "../script/MultiSigDeploy.s.sol";

contract MultiTest is Test {
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);

    MultiSig multiSig;

    function setUp() public {
        MultiSigScript script = new MultiSigScript();
        multiSig = script.run();
    }

    function testMultiSigSetup() public {
        assert(multiSig.getOwnersLength() == 3);
        assert(multiSig.getRequired() == 2);
    }

    /////////////////////////
    ////Constructor Tests////
    /////////////////////////

    function testRevertsIfNoOwners() public {
        vm.startBroadcast();
        vm.expectRevert();
        multiSig = new MultiSig(new address[](0), 1);
        vm.stopBroadcast();
    }

    function testRevertIfOwnersAreMoreThanRequired() public {
        vm.startBroadcast();
        vm.expectRevert();
        multiSig = new MultiSig(new address[](3), 2);
        vm.stopBroadcast();
    }

    function testRevertIfRequiredIsZero() public {
        vm.startBroadcast();
        vm.expectRevert();
        multiSig = new MultiSig(new address[](3), 0);
        vm.stopBroadcast();
    }

    function testRevertIfOwnerIsZeroAddress() public {
        address[] memory owners = new address[](2);
        owners[0] = address(0);
        vm.startBroadcast();
        vm.expectRevert();
        multiSig = new MultiSig(owners, 2);
        vm.stopBroadcast();
    }

    function testIsOwnerMappingUpdate() public {
        address[] memory owners = new address[](2);
        owners[0] = address(0x1);
        owners[1] = address(0x2);
        vm.startBroadcast();
        multiSig = new MultiSig(owners, 1);
        assertEq(multiSig.getIsOwner(address(0x1)), true);
        assertEq(multiSig.getIsOwner(address(0x2)), true);
        vm.stopBroadcast();
    }

    /////////////////////////
    ////Receive Test/////////
    /////////////////////////

    function testReceiveFunctionAndDepositEvent() public {
        vm.deal(address(1), 100);
        vm.startPrank(address(1));
        vm.expectEmit(true, false, false, true);
        emit Deposit(address(1), 95);
        address(multiSig).call{value: 95}("");
        vm.stopPrank();
        assertEq(address(multiSig).balance, 95);
    }

    modifier ownersPassed() {
        address owner1 = address(0x1);
        address owner2 = address(0x2);
        vm.deal(owner1, 100);
        vm.deal(owner2, 100);
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        multiSig = new MultiSig(owners, 1);
        _;
    }

    modifier submitPassed() {
        vm.prank(address(0x1));
        vm.expectEmit(true, false, false, true);
        emit Submit(0);
        multiSig.submit(address(0x3), 10, "");
        _;
    }

    modifier approvePassed(){
        vm.prank(address(0x1));
        vm.expectEmit(true, true, false, true);
        emit Approve(address(0x1), 0);
        multiSig.approve(0);
        _;

    }

    /////////////////////////
    ////Submit Function Tests//////
    /////////////////////////

  

    function testIFSubmitFunctionWorkingAndEmitSubmitEvent1() public ownersPassed submitPassed {
        assertEq(multiSig.getTransactionAddress(0), address(0x3));
    }

    function testIFSubmitFunctionWorkingAndEmitSubmitEvent2() public ownersPassed submitPassed {
        assertEq(multiSig.getTransactionValue(0), 10);
    }

    function testIFSubmitFunctionWorkingAndEmitSubmitEvent3() public ownersPassed submitPassed {
        assertEq(multiSig.getTransactionData(0), "");
    }

    function testIFSubmitFunctionWorkingAndEmitSubmitEvent4() public ownersPassed submitPassed {
        assertEq(multiSig.getTransactionExecuted(0), false);
    }

    ///////////////////////////////
    ////Approve Function Test//////
    ///////////////////////////////

    function testIfApproveFunctionIsWorkingCorrect() public ownersPassed submitPassed{
        vm.prank(address(0x1));
        vm.expectEmit(true, true, false, true);
        emit Approve(address(0x1), 0);
        multiSig.approve(0);
        assertEq(multiSig.getApproved(0, address(0x1)), true);
    }

    ////////////////////////////////////////
    ////getApprovalCount Function Test//////
    ////////////////////////////////////////

    function testIfGetApprovalCountFunctionIsWorkingCorrect() public ownersPassed submitPassed{
        vm.prank(address(0x1));
        vm.expectEmit(true, true, false, true);
        emit Approve(address(0x1), 0);
        multiSig.approve(0);
        assertEq(multiSig.getApprovalCount(0), 1);
    }

    //////////////////////
    ////Execute Test//////
    //////////////////////

   // function testIfExecuteFunctionIsWorkingCorrect() public ownersPassed submitPassed approvePassed{
        //console.log(address(0x3).balance);
        //vm.prank(address(0x1));
       // vm.expectEmit(true, false, false, true);
       // emit Execute(0);
        //multiSig.execute(0);
        //console.log(address(0x3).balance);
    //}

    /////////////////////////
    ////Revoke Test//////////
    /////////////////////////

    function testIfRevokeFunctionFailsWithFalseTxId() public ownersPassed submitPassed approvePassed{
        vm.prank(address(0x1));
        vm.expectRevert();
        multiSig.revoke(1);
    }

    function testIfRevokeFunctionWorkCorrect() public ownersPassed submitPassed approvePassed{
        vm.prank(address(0x1));
        vm.expectEmit(true, true, false, true);
        emit Revoke(address(0x1), 0);
        multiSig.revoke(0);
        assertEq(multiSig.getApproved(0, address(0x1)), false);
    }


    /////////////////////////
    ////Modifiers Test///////
    /////////////////////////

    function testOnlyOwnerModifier() public ownersPassed {
        vm.startBroadcast();
        vm.expectRevert();
        multiSig.submit(address(0x3), 10, "");
        vm.stopBroadcast();
    }

    function testTxExistsModifier() public ownersPassed{
        vm.startBroadcast();
        vm.expectRevert();
        multiSig.approve(0);
        vm.stopBroadcast();
    }

    function testNotApproveModifier() public ownersPassed submitPassed approvePassed{
        vm.startBroadcast();
        vm.expectRevert();
        multiSig.approve(1);
        vm.stopBroadcast();
    }

}

