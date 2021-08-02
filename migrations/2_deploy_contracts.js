const Poly721 = artifacts.require("./Poly721.sol");

module.exports = async (deployer, network) => {
  // OpenSea proxy registry addresses for rinkeby and mainnet.
  let proxyRegistryAddress = "";
  if (network === 'polygon') {
    proxyRegistryAddress = "0x58807baD0B376efc12F5AD86aAc70E78ed67deaE";
  } else if (network === 'mumbai') {
    proxyRegistryAddress = "0x58807baD0B376efc12F5AD86aAc70E78ed67deaE";
  } else {
    proxyRegistryAddress = "0x0000000000000000000000000000000000000000";
  }

  const contractName = process.env.NAME;
  const contractTicker = process.env.TICKER;
  const contractDescription = process.env.DESCRIPTION;

  await deployer.deploy(Poly721, proxyRegistryAddress, contractName, contractTicker, contractDescription, { gas: 5000000 });
  const contract = await Poly721.deployed();
  console.log('CONTRACT ADDRESS IS*||*' + contract.address + '*||*')
};
