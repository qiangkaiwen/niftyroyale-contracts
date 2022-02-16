const { MerkleTree } = require("merkletreejs")
const keccak256 = require("keccak256")

let allowlistAddresses = [0x2155bcea4f362d5d9ce67817b826a8f31b61d0bf]

const leafNodes = allowlistAddresses.map((addr) => keccak256(addr))
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPaires: true })
const rootHash = merkleTree.getRoot()
console.log("Allowlist MerKle Tree\n", merkleTree.toString())
const claimingAddress = leafNodes[0]
const hexProof = merkleTree.getHexProof(claimingAddress)
