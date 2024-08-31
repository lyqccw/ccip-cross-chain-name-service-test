// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import "src/CrossChainNameServiceRegister.sol";
import "src/CrossChainNameServiceReceiver.sol";
import "src/CrossChainNameServiceLookup.sol";

contract CrossChainNameServiceTest is Test {
    CCIPLocalSimulator public ccipLocalSimulator;
    CrossChainNameServiceRegister public registerContract;
    CrossChainNameServiceReceiver public receiverContract;
    CrossChainNameServiceLookup public lookupContract;

    address public alice = address(0xABCD); // Alice's EOA address for testing
    uint64 public sourceChainSelector;
    IRouterClient public sourceRouter;
    IRouterClient public destinationRouter;

    function setUp() public {
        // 创建 CCIPLocalSimulator 实例
        ccipLocalSimulator = new CCIPLocalSimulator();

        // 获取 Router 合约地址和其他配置
        (
            sourceChainSelector,
            sourceRouter,
            destinationRouter,
            ,
            ,
            ,

        ) = ccipLocalSimulator.configuration();

        // 创建 CrossChainNameServiceLookup 实例
        lookupContract = new CrossChainNameServiceLookup();

        // 创建 CrossChainNameServiceReceiver 实例
        receiverContract = new CrossChainNameServiceReceiver(
            address(destinationRouter),
            address(lookupContract),
            sourceChainSelector
        );

        // 创建 CrossChainNameServiceRegister 实例
        registerContract = new CrossChainNameServiceRegister(
            address(sourceRouter),
            address(lookupContract)
        );

        // 启用跨链服务
        registerContract.enableChain(
            sourceChainSelector,
            address(receiverContract),
            1000000 // 设置 gas limit
        );
    }

    function testRegisterAndLookup() public {
        // 调用 register 函数并注册 "alice.ccns"
        registerContract.register("alice.ccns");

        // 调用 lookup 函数并验证结果
        address resolvedAddress = lookupContract.lookup("alice.ccns");
        assertEq(
            resolvedAddress,
            alice,
            "The resolved address should be Alice's EOA address"
        );
    }
}
