# NFT Shards

Front-end code is found in `shards-app`, back-end code is found in `shards-protocol`

Play around with the contract on Rinkeby at: https://rinkeby.etherscan.io/address/0xF185889904B683E02374F26811D7076D002FDD4a

This contract helps you to fractionalize your NFT, to do so:
  1. Approve 0xF185889904B683E02374F26811D7076D002FDD4a to send your token (through the ERC721 contract)
  2. Call `mint` using our fractDAO contract to convert your ERC721 into ERC20s
  3. And you're done!

Governance:
  1. If you manage to obtain some `fDAOs` (the ERC20 token governing the fractDAO contract), you can `startVote()`, `vote()`, and `endVote()`
