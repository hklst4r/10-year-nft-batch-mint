// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Minter {
    address constant NFT  = 0x26D85A13212433Fe6A8381969c2B0dB390a0B0ae;

    constructor(uint256 tokenId) payable {
        address receiver; // FILL IN WITH YOUR RECEIVER ADDRESS
        assembly {
            let receiver_addr := receiver
            // --- call mint() ---
            mstore(0x00, shl(224, 0x1249c58b)) // 4-byte selector left-padded
            pop(call(gas(), NFT, 0, 0x00, 0x04, 0x00, 0x00))

            // --- call transferFrom(address(this), RECV, tokenId) ---
            // calldata layout: [selector|28z][from][to][id]
            mstore(0x00, shl(224, 0x23b872dd))
            mstore(0x4, address())            // from = this (owner)
            mstore(0x24, receiver_addr)                 // to   = receiver
            mstore(0x44, tokenId)              // id
            pop(call(gas(), NFT, 0, 0x00, 0x64, 0x00, 0x00))

            selfdestruct(receiver_addr)
        }
    }
}

contract BatchMint {
    function batchMint(uint num) external {
        // 1) Read totalSupply() once
        uint256 baseId;
        assembly {
            mstore(0x00, shl(224, 0x18160ddd))
            if iszero(staticcall(gas(), 0x26D85A13212433Fe6A8381969c2B0dB390a0B0ae, 0x00, 0x04, 0x00, 0x20)) { revert(0, 0) }
            baseId := mload(0x00)
        }

        unchecked {
            bytes memory creation = type(Minter).creationCode;
            uint256 clen = creation.length;
            for (uint256 i = 0; i < num; ++i) {
                assembly {
                    baseId := add(baseId, 1)
                    let totalLen := add(clen, 0x20)
                    let ptr := mload(0x40)              // free mem
                    mstore(0x40, add(ptr, and(add(totalLen, 0x3f), not(0x1f)))) // bump free mem (32-byte align)

                    // copy EphemeralMinter.creationCode to ptr
                    // memcpy in 32-byte chunks
                    let src := add(creation, 0x20)
                    for { let off := 0 } lt(off, clen) { off := add(off, 0x20) } {
                        mstore(add(ptr, off), mload(add(src, off)))
                    }
                    // append constructor arg (tokenId) at the end
                    mstore(add(ptr, clen), baseId)

                    // deploy
                    pop(create(0, ptr, totalLen))
                }
            }
        }
    }
}
